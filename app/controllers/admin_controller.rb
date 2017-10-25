# frozen_string_literal: true
require_relative 'application_controller'

# URL: /admin
class AdminController < ApplicationController
  helpers AdminHelper

  set :views, CSPReports.root + '/app/views/admin'
  provides 'html'

  get '/' do
    @domains = Domain.by_most_frequent
    erb :index
  end

  # TODO: paginate results
  # TODO: add search
  get '/domains/:domain' do
    @domain = params[:domain].to_s
    logger.info "DOMAIN: #{@domain}"
    @reports = Report.domain(@domain)
                     .order(:last_occurrence, Sequel.desc(:count), :id)
                     .limit(500) # sanity so the server doesn't crash
    erb :domain
  end

  get '/reports/:id' do
    @report = Report[params[:id]]
    return 404 unless @report
    @domain = @report.domain
    erb :report
  end
end
