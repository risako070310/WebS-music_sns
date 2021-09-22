require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require './models'
require 'dotenv/load'
require 'net/http'

enable :sessions

get '/' do
    @posts = Post.all
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
    if params[:file]
        image_url = "upload/#{params[:file][:filename]}"
        File.open("./public/#{image_url}", 'wb') do |f|
          f.write(params[:file][:tempfile].read)
        end
    end

    user = User.create(
        name: params[:name],
        password: params[:password],
        icon: image_url
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

get '/search' do
    unless session[:user]
        redirect '/'
    end
    erb :search
end

post '/search' do
    uri = URI("https://itunes.apple.com/search")
    uri.query = URI.encode_www_form({
        term: params[:keyword],
        limit: 20
    })
    res = Net::HTTP.get_response(uri)
    json = JSON.parse(res.body)
    @musics = json["results"]
    erb :search
end

post '/post' do
    Post.create(
        user_id: session[:user],
        jacket: params[:jacket],
        artist: params[:artist],
        album: params[:album],
        song: params[:song],
        sample: params[:sample],
        comment: params[:comment]
    )
    redirect '/profile'
end

get '/profile' do
    unless session[:user]
        redirect '/'
    end
    @user = User.find(session[:user])
    erb :home
end

get '/delete/:id' do
    post_ = Post.find(params[:id])
    unless session[:user]  == post_.user.id
        # マイページに遷移．
        redirect '/profile'
    end
    post_.destroy
    redirect '/profile'
end

get '/like/:post_id' do
    unless session[:user]
        redirect '/signup'
    end
    
    like = Like.find_by(user_id: session[:user], post_id: params[:post_id])
    if like.nil?
        Like.create(
            user_id: session[:user],
            post_id: params[:post_id]
        )
    else
        like.destroy
    end
    redirect '/'
end
