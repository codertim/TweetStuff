class Tribe < ActiveRecord::Base
  ZONE_ID = "tribal"
  belongs_to :user

  scope :sort_by_name, -> { order(:name => :asc) }
end
