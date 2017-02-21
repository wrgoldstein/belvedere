task :update, :project do |_t, args|
  project = args.project
  sql = "select distinct event from #{project}_production.tracks"
  events = Redshift.db.fetch(sql).select_map(:event)
  existing_events = Event.where(project: project).pluck(:event)
  events.select! { |e| !existing_events.include? e }
  puts "inserting #{events.size} events for project..."
  events.each { |e| Event.create! project: project, event: e }
end


task :add_pageviews, :project do |_t, args|
  # pageviews are treated separately in Segment, but could be part of funnels or segments
  project = args.project
  sql = "select distinct pagetype from util.pagetypes"
  pagetypes = Redshift.db.fetch(sql).select_map(:pagetypes)
  Event.where(event: pagetypes).delete
  puts "inserting #{pagetypes.size} events for project..."
  pagetypes.each { |e| Event.create! project: project, event: "viewed_#{e}_page" }
end
