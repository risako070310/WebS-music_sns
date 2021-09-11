require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require './models'
require 'dotenv/load'

enable :sessions

get '/' do
    erb :index
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
        puts session.to_hash
    end
    redirect '/'
end

get '/signup' do
    erb :sign_up
end

post '/signup' do
    user = User.create(
        name: params[:name],
        password: params[:password]
    )
    if user.persisted?
        session[:user] = user.id
    end
    redirect '/'
end

get '/logout' do
    session[:user] = nil
    redirect '/'
end