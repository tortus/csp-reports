require 'sinatra'
require 'sinatra/multi_route'
require 'json'
require 'pony'

unless settings.production?
  require 'dotenv'
  Dotenv.load
end

set :logging, true
set :csp_report_recipients, ENV.fetch('CSP_REPORT_RECIPIENTS')
set :csp_report_sender, ENV.fetch('CSP_REPORT_SENDER')

route :get, :post, '/' do
  request.body.rewind
  json = JSON.parse(request.body.read)

  text = JSON.pretty_generate(json)
  logger.info text

  Pony.mail(
    :to => settings.csp_report_recipients,
    :from => settings.csp_report_sender,
    :subject => 'CSP violation',
    :body => text
  )

  status 204
  body nil
end
