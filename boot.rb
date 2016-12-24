require 'sinatra/base'
require 'sinatra/multi_route'
require 'yaml'
require 'erb'
require 'json'
require 'pony'
require 'data_mapper'
require 'digest'
require 'digest/bubblebabble'

unless ''.respond_to?(:truncate)
  class String
    def truncate(truncate_at, options = {})
      return dup unless length > truncate_at

      omission = options[:omission] || '...'
      length_with_room_for_omission = truncate_at - omission.length
      stop =        if options[:separator]
        rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
      else
        length_with_room_for_omission
      end

      "#{self[0, stop]}#{omission}"
    end
  end
end

module CSPReports
  def self.root
    @_root ||= File.expand_path('..', __FILE__)
  end

  def self.config
    @_config ||= YAML.load(ERB.new(File.read(root + '/config/config.yml')).result)
  end

  def self.env
    @_env ||= ENV.fetch('RACK_ENV') { :development }.to_sym
  end
end

db = CSPReports.config.fetch('database')

DataMapper::Logger.new(STDOUT, CSPReports.env == :development ? :debug : :info)
DataMapper.setup(:default, "postgres://#{db.fetch('username')}:#{db.fetch('password')}@#{db.fetch('host')}/#{db.fetch('schema')}")
DataMapper::Model.raise_on_save_failure = true

# load models for datamapper
Dir.glob(File.expand_path('../app/models/*.rb', __FILE__)).each { |file| require file }

DataMapper.finalize

if ENV['MIGRATE'] =~ /\At(true)?|y(es)?|1/i
  puts "Migrating database..."
  DataMapper.auto_migrate!
  puts "Success!"
  exit 0
end

Dir.glob(File.expand_path('../app/{helpers,controllers}/*.rb', __FILE__)).each { |file| require file }
