task update: :project do |t, args|
  project = args.project
  sql = "select distinct event from #{project}_production.tracks")
  events = Redshift.db.fetch(sql).select_map(:event)
  existing_events = Event.where(project: project).pluck(:event)
  events.select! { |e| !existing_events.include? e }
  puts "inserting #{events.size} events for project..."
  events.each { |e| Event.create! project: project, event: e }
end
