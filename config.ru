require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV.fetch('RACK_ENV'){ :development }.to_sym )

require './boot'

map('/admin') { run AdminController }
map('/') { run ReportsController }
