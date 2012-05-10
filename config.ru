require 'bundler'
Bundler.require
require 'sinatra'
require 'gollum/frontend/app'
require 'openid/store/filesystem'
require 'rack/rewrite'

class Gollum::Wiki
  def default_committer_name
    self.class.default_committer_name
  end
  def default_committer_email
    self.class.default_committer_email
  end
end

class Wiki < Precious::App
  set :gollum_path, ENV['LOTR_REPO_PATH']
  set :wiki_options, {}
  use Rack::Session::Cookie, :key => 'endorwiki.session',
                             :secret => ENV['LOTR_SESSION_KEY']
  before do
    if not session[:user]
      redirect '/'
    end
    Gollum::Wiki.default_committer_name = session[:user]['name']
    Gollum::Wiki.default_committer_email = session[:user]['email']
  end
  get '/' do
    show_page_or_file('Welcome')
  end
end

class App < Sinatra::Base
  configure :development do
    use Rack::Reloader
    Sinatra::Application.reset!    
  end
  
  use Rack::Session::Cookie, :key => 'endorwiki.session',
                             :secret => ENV['LOTR_SESSION_KEY']
                             
  use OmniAuth::Strategies::GoogleApps, OpenID::Store::Filesystem.new('/tmp'), :domain => ENV['LOTR_GAPPS_DOMAIN']
  
  post '/auth/google_apps/callback' do
    auth_hash = request.env['omniauth.auth']
    user = session[:user] = auth_hash['user_info']
    if user['email']
      redirect '/'
    else
      session.clear
      redirect '/403'
    end
  end
  
  get '/update' do
    
  end
  
  get '/' do
    if not session[:user]
      erb :login
    else
      redirect '/wiki'
    end
  end
  
  get '/logout' do
    session.clear
    redirect '/'
  end
  
  not_found do
    if not request.path_info.start_with? '/auth'
      redirect "/wiki#{request.fullpath}"
    else
      "Not Found"
    end
  end
  


end

use Rack::Rewrite do
  rewrite %r{/(javascript|css|edit|create|preview|compare)(.*)}, '/wiki/$1$2'
end

map '/wiki' do
  run Wiki.new
end

map '/' do
  run App.new   
end