require 'spec_helper'

describe Funnel do
  it 'formats redshift response for chartjs' do
    redshift_response = [{:event=>"followed_artist", :count=>35394}, {:event=>"created_account", :count=>1542}]
    allow_any_instance_of(Funnel).to receive(:fetch).and_return(redshift_response)
    chartjs_format = {
          labels: ["followed_artist", "created_account"],
          datasets: [{
              label: 'count',
              data: [35394, 1542],
              backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)'
              ],
              borderColor: [
                  'rgba(255,99,132,1)',
                  'rgba(54, 162, 235, 1)'
              ],
              borderWidth: 1
          }]
      }
    f = Funnel.new(name: 'my funnel')
    expect(f.prepare_data(f.fetch)).to eq chartjs_format
  end

  it 'creates a sql query' do
    expected = <<-SQL
    WITH         followed_artist AS
              ( select anonymous_id, received_at
                from force_production.followed_artist
                where received_at > DATEADD('day', -30, CURRENT_DATE)

              )
    ,        created_account AS
              ( select anonymous_id, received_at
                from force_production.created_account
                where received_at > DATEADD('day', -30, CURRENT_DATE)
                and anonymous_id in (select anonymous_id from followed_artist)
              )
    ,        sent_artwork_inquiry AS
              ( select anonymous_id, received_at
                from force_production.sent_artwork_inquiry
                where received_at > DATEADD('day', -30, CURRENT_DATE)
                and anonymous_id in (select anonymous_id from created_account)
              )
    ,        time_constrained_created_account AS
              ( select created_account.anonymous_id, created_account.received_at
                from created_account
                inner join followed_artist first_event on created_account.anonymous_id = first_event.anonymous_id
                  and created_account.received_at > first_event.received_at
                  and dateadd('day', -7, created_account.received_at) <= first_event.received_at

              )
    ,        time_constrained_sent_artwork_inquiry AS
              ( select sent_artwork_inquiry.anonymous_id, sent_artwork_inquiry.received_at
                from sent_artwork_inquiry
                inner join followed_artist first_event on sent_artwork_inquiry.anonymous_id = first_event.anonymous_id
                  and sent_artwork_inquiry.received_at > first_event.received_at
                  and dateadd('day', -7, sent_artwork_inquiry.received_at) <= first_event.received_at
                inner join time_constrained_created_account tc0 on tc0.anonymous_id = sent_artwork_inquiry.anonymous_id
                      and first_event.received_at > tc0.received_at
              )
             select 'followed_artist' AS event, count(distinct anonymous_id)
            from followed_artist
    UNION ALL
            select 'created_account' AS event, count(distinct anonymous_id)
            from time_constrained_created_account
    UNION ALL
            select 'sent_artwork_inquiry' AS event, count(distinct anonymous_id)
            from time_constrained_sent_artwork_inquiry
    SQL
    f = Funnel.new(name: 'my funnel', events: ['followed_artist', 'created_account', 'sent_artwork_inquiry'])
    sql = f.sql.gsub(/\s+/, ' ').gsub(/,/, ",\n").downcase.strip
    exp = expected.gsub(/\s+/, ' ').gsub(/,/, ",\n").downcase.strip
    expect(sql).to eq(exp)
  end
end
