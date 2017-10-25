# Usage in Sinatra:
#
#     request.body.rewind
#     raw_text = request.body.read
#     report = Report.find_or_new_by_request_body(raw_text)
#     if report.new?
#       report.save
#     else
#       report.count += 1
#       report.save
#     end
#
# TODO: Coalesce reports from the same domain with matching violations.
# There are a lot of redundant reports for violations that happen the same on EVERY page.
# This would mostly involve checking for reports from the same domain with the same
# blocked URI and violated directive. We probably don't care about each unique document URI,
# and I'm not sure how to save that without a schema overhaul.
#
# TODO: Add ability to mark report as "resolved".
#
# TODO: Switch to Sequel or ActiveRecord, because this is awful.
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
  property :first_occurrence, DateTime
  property :last_occurrence, DateTime

  def formatted_body_json
    @formatted_json ||= JSON.pretty_generate(JSON.parse(body))
  end

  def self.find_or_new_by_request_body(raw_text)
    sha256 = Digest::SHA256.bubblebabble(raw_text)
    report = first(sha256: sha256)
    if !report
      report = new(sha256: sha256, raw_json: raw_text, first_occurrence: Time.now.utc)
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

  def increment!
    self.count += 1
    self.last_occurrence = Time.now.utc
    save!
  end

  def self.domain(domain)
    all(domain: domain)
  end
end
