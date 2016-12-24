class AdminController < Sinatra::Base

  helpers AdminHelper

  set :views, CSPReports.root + '/app/views/admin'

  provides 'html'

  get '/' do
    @domains = Domain.all
    erb :index
  end

  get '/domains/:domain' do
    @domain = params[:domain]
    @reports = Report.domain(domain: params[:domain])
    erb :domain
  end

  get '/reports/:id' do
    @report = Report.find(params[:id])
    erb :report
  end

end
