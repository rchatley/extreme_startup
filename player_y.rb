require 'rubygems'
require 'sinatra'

configure do
  set :port, 4568
end

get '/' do
  "4"
end