require 'rubygems'
require 'sinatra'

get '/' do
  "hi there #{Time.now}"
end