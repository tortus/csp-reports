require 'sinatra'
require 'sinatra/multi_route'
require 'json'
require 'pony'
require 'data_mapper'
require 'digest'
require 'digest/bubblebabble'

unless settings.production?
  require 'dotenv'
  Dotenv.load
end

DataMapper.setup(:default, 'sqlite:csp-reports.sqlite')

class Report
  include DataMapper::Resource
  property :sha256, Text, key: true
  property :body, Text, required: true
  property :count, Integer, default: 1, min: 1, required: true
end

DataMapper.finalize
DataMapper.auto_migrate! if ENV['MIGRATE'] =~ /\At(true)?|y(es)?|1/i


set :logging, true
set :csp_report_recipients, ENV.fetch('CSP_REPORT_RECIPIENTS')
set :csp_report_sender, ENV.fetch('CSP_REPORT_SENDER')

route :get, :post, '/' do
  request.body.rewind
  raw_text = request.body.read

  sha256 = Digest::SHA256.bubblebabble(raw_text)
  report = Report.get(sha256)
  if !report
    json = JSON.parse(raw_text)
    formatted_json = JSON.pretty_generate(json)

    report = Report.create!(
      sha256: sha256,
      body: raw_text,
      count: 1
    )

    logger.info "Registered new problem:\n#{formatted_json}"

    Pony.mail(
      :to => settings.csp_report_recipients,
      :from => settings.csp_report_sender,
      :subject => 'CSP violation',
      :body => formatted_json
    )
  else
    report.count += 1
    report.save!
    logger.info "Registered new occurrence of problem #{sha256} Count: #{report.count}"
  end

  status 204
  body nil
end
