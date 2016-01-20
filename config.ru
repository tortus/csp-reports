require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV.fetch('RACK_ENV'){ :development }.to_sym )

require './app'
run Sinatra::Application
