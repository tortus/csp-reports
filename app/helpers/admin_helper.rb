module AdminHelper
  include ERB::Util

  def domain_path(domain)
    if domain
      if domain.respond_to?(:domain)
        domain = domain.domain
      end
      url("/domains/#{URI.encode(domain)}")
    end
  end

  def report_path(report)
    if report
      url("/reports/#{report.id}")
    end
  end

end
