require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV.fetch('RACK_ENV'){ :development }.to_sym )

require_relative 'boot'

if ENV['RACK_ENV'] == 'development'
  use Rack::Static, urls: ['/css', '/images', '/js'], root: 'public'
end

map('/admin') { run AdminController }
map('/') { run ReportsController }
