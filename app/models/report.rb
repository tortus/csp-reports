# TODO: don't treat same violated directive at separate URI's on the same domain
# as different errors.
#
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

  def self.domain(domain)
    all(domain: domain)
  end
end
