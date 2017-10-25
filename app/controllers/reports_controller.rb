# /
class ReportsController < Sinatra::Base
  enable :logging

  get '/' do
    redirect to('https://www.tortus.com/')
  end

  post '/' do
    request.body.rewind
    raw_text = request.body.read

    return 422 if raw_text.empty?

    report = Report.find_or_new_by_request_body(raw_text)
    return 422 unless report.valid?

    if report.new?
      report.save
      logger.info "Registered new problem:\n#{report.formatted_body_json}"

      if CSPReports.config['notifications']['enabled']
        Pony.mail(
          to: settings.notifications['recipients'],
          from: settings.notifications['sender'],
          subject: 'CSP violation',
          body: report.formatted_body_json
        )
      end
    else
      report.increment!
      logger.info "Registered new occurrence of problem #{report.sha256} Count: #{report.count}"
    end

    status 204
    body nil
  end
end
