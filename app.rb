require 'sinatra'
require 'mongoid'

require 'json'
require 'erb'


require './lib/redshift'
require './lib/funnel'
require './lib/event'
require './lib/segment'

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


FAKESEGMENT = %{[{"date":"2017-01-31","event":"sent_artwork_inquiry","count":151},{"date":"2017-02-02","event":"sent_artwork_inquiry","count":230},{"date":"2017-01-31","event":"clicked_article_impression","count":1909},{"date":"2017-02-02","event":"clicked_article_impression","count":632},{"date":"2017-01-28","event":"sent_artwork_inquiry","count":142},{"date":"2017-01-30","event":"sent_artwork_inquiry","count":244},{"date":"2017-02-03","event":"sent_artwork_inquiry","count":38},{"date":"2017-01-28","event":"clicked_article_impression","count":1621},{"date":"2017-01-30","event":"clicked_article_impression","count":2250},{"date":"2017-02-03","event":"clicked_article_impression","count":68},{"date":"2017-01-27","event":"sent_artwork_inquiry","count":194},{"date":"2017-01-29","event":"sent_artwork_inquiry","count":271},{"date":"2017-01-27","event":"clicked_article_impression","count":1359},{"date":"2017-01-29","event":"clicked_article_impression","count":1949},{"date":"2017-02-01","event":"sent_artwork_inquiry","count":175},{"date":"2017-02-01","event":"clicked_article_impression","count":958}]}
# segment
get '/segment/data' do
  sql = Segment.sql_for_event(params['events'], params['date_range'])
  puts sql
  Redshift.safe_fetch(sql).all.to_json
end

get '/segment/new' do
  erb :'segment/new'
end

# events
get '/events/:project' do
  Event.where(project: params['project'].downcase).pluck(:event).to_json
end
