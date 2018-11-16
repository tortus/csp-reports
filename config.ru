require 'rubygems'
require 'bundler'

# sinatra uses APP_ENV, so just copy it from RACK_ENV if missing
if ENV['RACK_ENV'] && !ENV['APP_ENV']
  ENV['APP_ENV'] = ENV['RACK_ENV']
# if APP_ENV is set, make that authoritative instead
elsif ENV['APP_ENV'] && ENV['APP_ENV'] != ENV['RACK_ENV']
  ENV['RACK_ENV'] = ENV['APP_ENV']
end

puts "Booting in '#{ENV['RACK_ENV']}' mode"

Bundler.require(:default, ENV.fetch('RACK_ENV'){ :development }.to_sym )

require_relative 'boot'

if ENV['RACK_ENV'] == 'development'
  use Rack::Static, urls: ['/css', '/images', '/js'], root: 'public'
end

map('/admin') { run AdminController }
map('/') { run ReportsController }
