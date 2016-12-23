class ReportsController < Sinatra::Base
  register Sinatra::MultiRoute

  route :get, :post, '/' do
    request.body.rewind
    raw_text = request.body.read

    report = Report.find_or_new_by_request_body(raw_text)

    if report.new?
      report.save
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
      report.save
      logger.info "Registered new occurrence of problem #{report.sha256} Count: #{report.count}"
    end

    status 204
    body nil
  end

end
