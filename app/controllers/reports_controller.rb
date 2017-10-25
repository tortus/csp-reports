# /
class ReportsController < Sinatra::Base
  enable :logging

  get '/' do
    redirect to('https://www.tortus.com/')
  end

  post '/' do
    request.body.rewind
    raw_text = request.body.read

    if raw_text.empty?
      return 422
    end

    report = Report.find_or_new_by_request_body(raw_text)
    unless report.valid?
      return 422
    end

    if report.new?
      report.save
      logger.info "Registered new problem:\n#{report.formatted_body_json}"

      if CSPReports.config['notifications']['enabled']
        Pony.mail(
          :to => settings.notifications['recipients'],
          :from => settings.notifications['sender'],
          :subject => 'CSP violation',
          :body => report.formatted_body_json
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
