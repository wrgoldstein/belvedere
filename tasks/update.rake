task update: :project do |t, args|
  sql = "select distinct event from #{args.project}_production.tracks")
  events = Redshift.db.fetch(sql).select_map(:event)
  existing_events = Event.where(project: 'force').pluck(:event)
  events.select! { |e| !existing_events.include? e }
  puts "inserting #{events.size} events for force..."
  events.each { |e| Event.create! project: 'force', event: e }
end