class Segment
  def self.sql_for_event(project, events, date_range)
    part, value = parse_date_range(date_range)
    events = events.split(',')
    events.map do |event|
      <<-SQL
        (SELECT DATE_TRUNC('#{part}', received_at)::DATE as "date", '#{event}' as "event", count(*)
        FROM
          #{project}_production.#{event}
        WHERE received_at >= DATEADD('#{part}', -#{value}, CURRENT_DATE)
        GROUP BY 1
        ORDER BY 1)
      SQL
    end.join(' UNION ALL ')
  end

  def self.parse_date_range(date_range)
    trunc = date_range.downcase[/day/] || 'month'
    value = date_range[/\d+/]
    [trunc, value]
  end
end
