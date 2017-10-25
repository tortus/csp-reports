# frozen_string_literal: true
class ApplicationController < Sinatra::Base
  configure :development, :production do
    logger = Logger.new(File.open("#{CSPReports.root}/log/#{environment}.log", 'a'))
    logger.level = Logger::DEBUG if development?
    set :logger, logger
  end

  helpers Sinatra::CustomLogger
end
