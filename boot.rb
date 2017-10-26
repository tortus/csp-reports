require 'sinatra/base'
require 'sinatra/multi_route'
require 'sinatra/custom_logger'
require 'logger'
require 'yaml'
require 'erb'
require 'json'
require 'pony'
require 'sequel'
require 'digest'
require 'digest/bubblebabble'
require 'tzinfo'

# Add String#truncate if it doesn't exist
unless ''.respond_to?(:truncate)
  class String
    def truncate(truncate_at, options = {})
      return dup unless length > truncate_at

      omission = options[:omission] || '...'
      length_with_room_for_omission = truncate_at - omission.length
      stop = if options[:separator]
        rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
      else
        length_with_room_for_omission
      end

      "#{self[0, stop]}#{omission}"
    end
  end
end

# Base root configuration module
module CSPReports
  class << self
    def root
      @_root ||= File.expand_path('..', __FILE__).freeze
    end

    def config
      @_config ||= YAML.safe_load(
        ERB.new(
          File.read(File.join(root, 'config', 'config.yml'))
        ).result
      ).freeze
    end

    def env
      @_env ||= ENV.fetch('APP_ENV') { :development }.to_sym
    end

    attr_writer :time_zone

    def time_zone
      @time_zone ||= TZInfo::Timezone.get(config.fetch('time_zone'))
    end

    def timestamp_format
      '%a %b %-d %Y %-l:%M %p'.freeze
    end

    attr_accessor :db

    attr_writer :logger

    def logger
      unless @logger
        file = File.open("#{CSPReports.root}/log/#{env}.log", 'a')
        file.sync = true
        @logger = Logger.new(file)
        if env == :production
          @logger.level = Logger::INFO
        else
          @logger.level = Logger::DEBUG
        end
      end
      @logger
    end
  end
end

puts "APP_ENV: #{ENV['APP_ENV']}"
puts "RACK_ENV: #{ENV['RACK_ENV']}"

# Create the database connection
db_url = CSPReports.config.fetch('database_url', nil)
unless db_url
  db = CSPReports.config.fetch('database')
  username = CGI.escape(db.fetch('username') || '')
  passwd = CGI.escape(db.fetch('password') || '')
  db_url = "postgres://#{username}:#{passwd}@#{db.fetch('host')}/#{db.fetch('schema')}"
end
CSPReports.db = Sequel.connect(db_url, logger: (CSPReports.logger unless CSPReports.env == :production))

# load models
begin
  Dir.glob(File.expand_path('../app/models/*.rb', __FILE__)).each do |file|
    require file
  end
rescue Sequel::DatabaseError
  puts 'WARNING: NO DATABASE'
end

# load all helpers and controllers
require_relative 'app/helpers/admin_helper'
require_relative 'app/controllers/application_controller'
require_relative 'app/controllers/reports_controller'
require_relative 'app/controllers/admin_controller'
