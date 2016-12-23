class AdminController < Sinatra::Base
  set :views, CSPReports.root + '/app/views/admin'
end
