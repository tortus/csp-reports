require 'sinatra'
require 'sinatra/multi_route'
require 'sinatra/config_file'
require 'json'
require 'pony'
require 'data_mapper'
require 'digest'
require 'digest/bubblebabble'

config_file './config.yml'

DataMapper.setup(:default, "postgres://#{settings.database['username']}:#{settings.database['password']}@#{settings.database['host']}/#{settings.database['schema']}")

# TODO: don't treat same violated directive at separate URI's on the same domain
# as different errors.
class Report
  include DataMapper::Resource

  property :id, Serial
  property :sha256, Text, key: true
  property :body, Text, required: true
  property :count, Integer, default: 1, min: 1, required: true
  property :domain, Text
  property :document_uri, Text
  property :referrer, Text
  property :violated_directive, Text
  property :original_policy, Text
  property :blocked_uri, Text

  def formatted_body_json
    @formatted_json ||= JSON.pretty_generate(JSON.parse(body))
  end

  def self.find_or_new_by_request_body(raw_text)
    sha256 = Digest::SHA256.bubblebabble(raw_text)
    report = first(sha256: sha256)
    if !report
      report = new(sha256: sha256, raw_json: raw_text)
    end
    report
  end

  def raw_json=(raw_text)
    self.body = raw_text
    json = JSON.parse(raw_text)
    @formatted_json = JSON.pretty_generate(json)
    if (report = json['csp-report'])
      self.document_uri       = report['document-uri']
      self.domain             = URI.parse(document_uri).host.downcase
      self.referrer           = report['referrer']
      self.violated_directive = report['violated-directive']
      self.original_policy    = report['original-policy']
      self.blocked_uri        = report['blocked-uri']
    end
  end
end

DataMapper.finalize

if ENV['MIGRATE'] =~ /\At(true)?|y(es)?|1/i
  puts "Migrating database..."
  DataMapper.auto_migrate!
  puts "Success!"
  exit 0
end

route :get, :post, '/' do
  request.body.rewind
  raw_text = request.body.read

  report = Report.find_or_new_by_request_body(raw_text)

  if report.new?
    report.save!
    logger.info "Registered new problem:\n#{report.formatted_body_json}"

    if settings.notifications['enabled']
      Pony.mail(
       :to => settings.notifications['recipients'],
       :from => settings.notifications['sender'],
       :subject => 'CSP violation',
       :body => report.formatted_body_json
      )
    end
  else
    report.count += 1
    report.save!
    logger.info "Registered new occurrence of problem #{report.sha256} Count: #{report.count}"
  end

  status 204
  body nil
end
