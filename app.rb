require 'sinatra'
require 'mongoid'

require 'json'
require 'erb'


require './lib/redshift'
require './lib/funnel'
require './lib/event'

Mongoid.load! 'mongoid.yml', :development

set :public_folder, 'web/public'
set :views, 'web/views'


get '/' do
  erb :index
end

# funnel
get '/funnel/index' do
  erb :'funnel/index', locals: { funnel: params['funnel'] }
end

get '/funnel/new' do
  erb :'funnel/new'
end

post '/funnel/new' do
  funnel = Funnel.create_from_params!(params)
  redirect "/funnel/index?funnel=#{funnel.id}" if funnel
  'failed'
end

get '/funnel/:name' do
  Funnel.where(name: params['name']).first.to_json
end

get '/funnel/:name/data' do
  name = URI.decode(params['name'])
  funnel = Funnel.where(name: name).first
  funnel.prepare_data(funnel.fetch).to_json
end

get '/funnels' do
  Funnel.pluck(:name).to_json
end

get '/events/:project' do
  Event.where(project: params['project'].downcase).pluck(:event).to_json
end


