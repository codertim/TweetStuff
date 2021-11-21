class TweetStyle < ActiveRecord::Base
  DEFAULT_ZONE = "DEMOCRACY"

  belongs_to :user
end
