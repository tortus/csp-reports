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
class Report < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:sha256, :body]
    errors.add(:count, 'must be greater than or equal to 1') if count && count < 1
  end

  def formatted_body_json
    @formatted_json ||= JSON.pretty_generate(JSON.parse(body))
  end

  def self.find_or_new_by_request_body(raw_text)
    sha256 = Digest::SHA256.bubblebabble(raw_text)
    report = dataset.sha256(sha256).first
    unless report
      timestamp = Time.now.utc
      report = new(
        sha256: sha256,
        raw_json: raw_text,
        count: 1,
        first_occurrence: timestamp,
        last_occurrence: timestamp
      )
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
    save(raise_on_failure: true)
  end

  dataset_module do
    def domain(domain)
      where(domain: domain.to_s)
    end

    def sha256(sha256)
      where(sha256: sha256.to_s)
    end
  end
end
