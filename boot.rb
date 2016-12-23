require 'sinatra/base'
require 'sinatra/multi_route'
require 'yaml'
require 'erb'
require 'json'
require 'pony'
require 'data_mapper'
require 'digest'
require 'digest/bubblebabble'

module CSPReports
  def self.root
    @root ||= File.expand_path('..', __FILE__)
  end

  def self.config
    @config ||= YAML.load(ERB.new(File.read(root + '/config/config.yml')).result)
  end
end

db = CSPReports.config.fetch('database')

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
