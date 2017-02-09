require 'sinatra'
require 'mongoid'

require 'json'
require 'erb'


require './lib/redshift'
require './lib/funnel'
require './lib/event'
require './lib/segment'

Mongoid.load! 'mongoid.yml', settings.environment

set :public_folder, 'web/public'
set :views, 'web/views'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'admin' and password == 'admin'
end

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
  if name == 'fake'
    return [{:event=>"followed_artist", :count=>3594}, {:event=>"created_account", :count=>1542}].to_json
  end
  funnel = Funnel.where(name: name).first
  sql = funnel.sql(params['date_range'], params['days_to_complete'])
  Redshift.safe_fetch(sql).all.to_json
end

get '/funnels' do
  Funnel.pluck(:name).to_json
end

# segment
get '/segment/data' do
  sql = Segment.sql_for_event(params['project'], params['events'], params['date_range'])
  Redshift.safe_fetch(sql).all.to_json
end

get '/segment/new' do
  erb :'segment/new'
end

# events
get '/events/:project' do
  Event.where(project: params['project'].downcase).pluck(:event).to_json
end

