# frozen_string_literal: true
module AdminHelper
  include ERB::Util

  def domain_path(domain)
    return unless domain
    if domain.respond_to?(:domain)
      domain = domain.domain
    end
    url("/domains/#{URI.encode_www_form_component(domain)}")
  end

  def report_path(report)
    return unless report
    url("/reports/#{report.id}")
  end

  # Convert a report's last_occurrence to the local time zone and format it
  def report_timestamp(report)
    return unless report &. last_occurrence
    tz = CSPReports.time_zone
    tz.utc_to_local(report.last_occurrence).strftime(CSPReports.timestamp_format)
  end
end
