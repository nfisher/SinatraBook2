require 'rubygems'
require 'cgi'
require 'sinatra'
require 'oauth2'
require 'json'
require 'haml'
require 'facebook_config'


GRAPH_URL = 'https://graph.facebook.com'


enable :sessions


get '/' do
	user = JSON.parse(access_token.get '/me')
	user.inspect
end


# The beginning of your FB Connect Authentication journey.
#
#
get '/auth/facebook/?' do
	redirect client.web_server.authorize_url(:redirect_uri => redirect_uri, :scope => 'offline_access')
end


# A callback for authentication...you'll land here when you've authenticated with fb.
#
#
get '/auth/facebook/callback' do
	client.web_server.access_token(params[:code], :redirect_uri => redirect_uri)
	redirect '/'
end


def client
	OAuth2::Client.new(APP_KEY, APP_SECRET, :site => GRAPH_URL)
end


def fbs_params
	fbs = request.cookies.map {|k,v| v if k =~ /^fbs_\d+$/}.compact.first
	# TODO: Validate cookie parameters here
	CGI::parse(fbs) unless fbs.nil?
end


def access_token
	redirect '/auth/facebook' if fbs_params.nil?
	token = fbs_params['access_token'].first
	OAuth2::AccessToken.new(client, token)
end


def redirect_uri
	uri = URI.parse(request.url)
	uri.path = '/auth/facebook/callback'
	uri.query = nil
	uri.to_s
end
