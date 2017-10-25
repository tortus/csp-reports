# frozen_string_literal: true
class ApplicationController < Sinatra::Base
  if CSPReports.env == :development
    enable :logging
  else
    set :logging, nil
    use Rack::Logger
  end
end
