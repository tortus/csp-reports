class AdminController < Sinatra::Base

  helpers AdminHelper

  enable :logging
  set :views, CSPReports.root + '/app/views/admin'
  provides 'html'

  get '/' do
    @domains = Domain.all
    erb :index
  end

  # TODO: paginate results
  # TODO: add search
  get '/domains/:domain' do
    @domain = params[:domain].to_s
    logger.info "DOMAIN: #{@domain}"
    @reports = Report.domain(@domain).all(order: [:count.desc, :blocked_uri, :document_uri])
    erb :domain
  end

  get '/reports/:id' do
    @report = Report.first(id: params[:id])
    return 404 unless @report
    @domain = @report.domain
    erb :report
  end

end
