require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV.fetch('RACK_ENV'){ :development }.to_sym )

require_relative 'boot'

if ENV['RACK_ENV'] == 'development'
  use Rack::Static, urls: ['/css', '/images', '/js'], root: 'public'
# elsif ENV['RACK_ENV'] == 'production'
#   log = File.new('log/production.log', 'a+')
#   $stdout.reopen(log)
#   $stderr.reopen(log)
#   $stdout.sync = true
#   $stderr.sync = true
end

map('/admin') { run AdminController }
map('/') { run ReportsController }
