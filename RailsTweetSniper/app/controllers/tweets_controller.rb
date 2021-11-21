class TweetsController < ApplicationController
  def index
    @tweets = ["hello", "world"]
    if Tweet::ZONES.include?(params[:zone])
      logger.debug("##### TweetsController#index - zone ok")
    else
      logger.warn("##### TweetsController#index - WARNING - zone not found = #{params[:zone]}")
    end
  end

end

