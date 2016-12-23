class AdminController < Sinatra::Base

  set :views, CSPReports.root + '/app/views/admin'

  provides 'html'

  get '/' do
    @domains = Domain.all
    erb :index
  end

  get '/domains/:domain' do
    @reports = Report.where(domain: params[:domain]).all
    erb :domain
  end

  get '/reports/:id' do
    @report = Report.find(params[:id])
    erb :report
  end

end
