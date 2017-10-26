# frozen_string_literal: true
class ApplicationController < Sinatra::Base
  configure :development, :production do
    set :logger, CSPReports.logger
  end

  helpers Sinatra::CustomLogger
end
