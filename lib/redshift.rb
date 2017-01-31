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
    db.fetch(sql)
  rescue PG::ConnectionBad
    db.fetch(sql) if tries == 0
  end

  def self.events(project)
    db.fetch("select distinct event from #{project}_production.tracks").select_map(:event)
  end
end
