require 'bundler'
Bundler.require

require './lib/ext/gollum'
require './lib/configuration.rb'
require './lib/wiki.rb'

class App < Sinatra::Base
  configure :development do
    use Rack::Reloader
    Sinatra::Application.reset!
  end

  use Rack::Session::Cookie, key: CONFIG[:session][:key],
                             secret: CONFIG[:session][:secret]

  use OmniAuth::Builder do
    provider :google_apps, store: OpenID::Store::Filesystem.new('/tmp'),
                           domain: CONFIG[:google][:domain]
  end

  helpers do
    def auth_hash
      request.env['omniauth.auth']
    end
  end

  # Callback for OpenID login.
  post '/auth/google_apps/callback' do
    unless auth_hash[:provider] == 'google_apps'
      403
    end
    user = session[:user] = auth_hash['info']
    if user['email']
      redirect '/'
    else
      session.clear
      403
    end
  end

  post '/auth/google_oauth2/callback' do
    unless auth_hash[:provider] == 'google_oauth2'
      403
    end

    user = auth_hash['info']
    if email = user['email'] && email.end_with?("@#{CONFIG[:google][:domain]}")
      session[:user] = user
      redirect '/'
    else
      session.clear
      403
    end
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

  error 403 do
    "Forbidden"
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
