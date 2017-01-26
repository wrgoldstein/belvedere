class Event
  include Mongoid::Document

  field :project, type: String
  field :event, type: String
  field :count, type: Integer
  field :params, type: String
end
