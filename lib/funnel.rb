class Funnel
  include Mongoid::Document
  include Mongoid::Timestamps



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
    days_ago = date_range[/\d+/]
    days_to_complete = days_to_complete[/\d+/]
    with_statements = create_with_statements_from_events(days_ago, days_to_complete)
    main_bodies = select_from_with_tables
    main_body = main_bodies.join(" UNION ALL\n")
    create_sql_from_pieces(with_statements, main_body)
  end

  private

  def create_with_statements_from_events(days_ago, days_to_complete)
    [
      events.map.with_index { |event, i| with_statement(event, i, days_ago) },
      events.map.with_index { |event, i| time_constrained_with_statement(event, i, days_ago, days_to_complete) }.compact
    ].flatten
  end

  def with_statement(event, i, days_ago)
    matched = /viewed_(.*)_page/.match(event)
    pagetype = matched.captures.first if matched
    table = pagetype.nil? ? "#{project}_production.#{event}" : "analytics.#{project.chomp('_production')}_pages"

    <<-SQL
      #{event} AS
        ( select anonymous_id, sent_at
          from #{table}
          where sent_at >= DATEADD('day', -#{days_ago}, CURRENT_DATE)
            #{ !pagetype.nil? ? "and pagetype = '#{pagetype}'" : ''}
            #{ i > 0 ? "and anonymous_id in (select anonymous_id from #{events[i -1]})" : ''}
        )
    SQL
  end

  def time_constrained_with_statement(event, i, days_ago, days_to_complete)
    return if i == 0
    previous = "inner join time_constrained_#{events[i-1]} tc0 on tc0.anonymous_id = #{event}.anonymous_id
                  and first_event.sent_at <= tc0.sent_at"
    <<-SQL
        time_constrained_#{event} AS
          ( select #{event}.anonymous_id, #{event}.sent_at
            from #{event}
            inner join #{events[0]} first_event on #{event}.anonymous_id = first_event.anonymous_id
              and #{event}.sent_at >= first_event.sent_at
              and dateadd('day', -#{days_to_complete}, #{event}.sent_at) <= first_event.sent_at
            #{i > 1 ? previous : ''}
          )
      SQL
  end

  def select_from_with_tables
      events.map.with_index { |event, i| select_from_with_table(event, i) }
  end

  def select_from_with_table(event, i)
    <<-SQL
        select '#{event}' AS event, count(distinct anonymous_id)
        from #{i > 0 ? 'time_constrained_' : ''}#{event}
      SQL
  end

  def create_sql_from_pieces(with_statements, main_body)
    "WITH #{with_statements.join(',')} #{main_body}"
  end


end
