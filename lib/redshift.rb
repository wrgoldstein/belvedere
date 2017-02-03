require 'sequel'

module Redshift
  def self.db
    @db ||= Sequel.connect(
      ENV['REDSHIFT_URL'],
      port: 5439,
      force_standard_strings: false,
      client_min_messages: ''
    )
  end

  def self.safe_fetch(sql, tries=0)
    if sql == 'fake'
      s = Struct.new('Faker', :all)
      dat = [{:event=>"followed_artist", :count=>35394}, {:event=>"created_account", :count=>1542}] 
      return s.new(dat) 
    end
    db.fetch(sql)
  rescue PG::ConnectionBad
    db.fetch(sql) if tries == 0
  end
end
