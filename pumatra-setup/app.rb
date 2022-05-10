# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'

get '/' do
  'Hello world!'
end

get '/hello-world' do
  'This another hello world!'
end
