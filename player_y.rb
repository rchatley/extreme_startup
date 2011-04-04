require 'rubygems'
require 'sinatra'

configure do
  set :port, 4568
end

get '/' do
  "hi there from Y #{Time.now}"
end