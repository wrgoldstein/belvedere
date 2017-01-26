task :update do
  events = Redshift.events('force')
  existing_events = Event.where(project: 'force').pluck(:event)
  events.select! { |e| !existing_events.include? e }
  puts "inserting #{events.size} events for force..."
  events.each { |e| Event.create! project: 'force', event: e }
end