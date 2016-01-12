require 'sinatra'

get '/' do
  Pony.mail(:to => 'you@example.com', :from => 'me@example.com', :subject => 'hi', :body => 'Hello there.')
end
