class Funnel
  include Mongoid::Document
  include Mongoid::Timestamps

  BG_COLORS = [
    'rgba(255, 99, 132, 0.2)', 
    'rgba(54, 162, 235, 0.2)',
    'rgba(255, 206, 86, 0.2)',
    'rgba(75, 192, 192, 0.2)',
    'rgba(153, 102, 255, 0.2)',
    'rgba(255, 159, 64, 0.2)'
  ]

  BORDER_COLORS = [
    'rgba(255,99,132,1)',
    'rgba(54, 162, 235, 1)',
    'rgba(255, 206, 86, 1)',
    'rgba(75, 192, 192, 1)',
    'rgba(153, 102, 255, 1)',
    'rgba(255, 159, 64, 1)'
  ]

  field :name, type: String
  field :project, type: String
  field :events, type: Array

  validates_uniqueness_of :name

  def self.create_from_params!(params)
    events = params.select { |k,v| k[/events-input-/] }.values
    funnel = new(name: params['name'], project: params['project'], events: events)
    funnel.save
    funnel
  end

  def sql(date_range, days_to_complete)
    return 'fake' if name == 'fake'
    
    days_ago = date_range[/\d+/]
    days_to_complete = days_to_complete[/\d+/]

    ctes = events.map.with_index do |event, i|
      <<-SQL
        #{event} AS
          ( select anonymous_id, received_at
            from #{project}_production.#{event}
            where received_at > DATEADD('day', -#{days_ago}, CURRENT_DATE)
            #{ i > 0 ? "and anonymous_id in (select anonymous_id from #{events[i -1]})" : ''}
          )
      SQL
    end

    ctes += events.map.with_index do |event, i|
      previous = "inner join time_constrained_#{events[i-1]} tc0 on tc0.anonymous_id = #{event}.anonymous_id 
                  and first_event.received_at > tc0.received_at"
      next if i == 0
      <<-SQL
        time_constrained_#{event} AS 
          ( select #{event}.anonymous_id, #{event}.received_at
            from #{event}
            inner join #{events[0]} first_event on #{event}.anonymous_id = first_event.anonymous_id
              and #{event}.received_at > first_event.received_at
              and dateadd('day', -#{days_to_complete}, #{event}.received_at) <= first_event.received_at
            #{i > 1 ? previous : ''}
          )
      SQL
    end.compact

    main_body = events.map.with_index do |event, i|
      <<-SQL
        select '#{event}' AS event, count(distinct anonymous_id)
        from #{i > 0 ? 'time_constrained_' : ''}#{event}
      SQL
    end

    "WITH #{ctes.join(',')} #{main_body.join(%(UNION ALL\n))}"
  end

  def prepare_data(data)
    data = data.sort_by { |e| -e[:count] }
    labels = data.map { |e| e[:event] }
    values = data.map { |e| e[:count] }
    {
      labels: labels,
      datasets: [{
        label: 'count',
        data: values,
        backgroundColor: BG_COLORS[0..labels.size - 1],
        borderColor: BORDER_COLORS[0..labels.size - 1],
        borderWidth: 1
        }]
    }
  end
end
