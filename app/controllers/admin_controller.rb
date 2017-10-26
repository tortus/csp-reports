# frozen_string_literal: true

# URL: /admin
class AdminController < ApplicationController
  helpers AdminHelper

  set :views, "#{CSPReports.root}/app/views/admin"
  provides 'html'

  get '/' do
    logger.info "GET /admin"
    @domains = Domain.by_most_frequent
    erb :index
  end

  # TODO: paginate results
  # TODO: add search
  get '/domains/:domain' do
    logger.info "REPORT domain: #{params[:domain]}"
    @domain = params[:domain].to_s
    logger.info "DOMAIN: #{@domain}"
    @reports = Report.domain(@domain)
                     .order(:last_occurrence, Sequel.desc(:count), :id)
                     .limit(500) # sanity so the server doesn't crash
    erb :domain
  end

  get '/reports/:id' do
    id = params[:id]
    logger.info "REPORT ID: #{id}"
    return 404 unless id.match?(/\A\d+\z/)
    @report = Report[id.to_i]
    logger.debug "REPORT: #{@report.inspect}"
    return 404 unless @report
    @domain = @report.domain
    erb :report
  end

  not_found do
    send_file "#{CSPReports.root}/public/404.html", status: 404
  end
end
