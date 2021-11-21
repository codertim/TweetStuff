

class Tweets

  def self.get_tweets_of_friends(credentials_token, credentials_secret, session)
    return @friend_tweets if @friend_tweets

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_key
      config.consumer_secret     = Rails.application.secrets.twitter_secret
      config.access_token        = credentials_token
      config.access_token_secret = credentials_secret
    end

    Rails.logger.debug("Tweets#get_tweets_of_friends - client = #{client}")
    Rails.logger.debug("Tweets#get_tweets_of_friends - client.inspect = #{client.inspect}")
    # Rails.logger.debug("Tweets#get_tweets_of_friends - First text: |#{client.home_timeline.first.text}")
    client_friends = client.friends
    Rails.logger.debug("Tweets#get_tweets_of_friends - friends class: |#{client_friends.class}|")
    Rails.logger.debug("Tweets#get_tweets_of_friends - friends: |#{client_friends.to_a}|")
    friends_array = client_friends.to_a
    # Rails.logger.debug("Followers: |#{client.friends[:users].first.name}|")

    friend_tweets = client_friends.map do |user|
      Rails.logger.debug("Tweet#get_tweets_of_friends - Calling client.user_timeline on user# #{user.screen_name}")
      # most_recent_texts = Twitter.user_timeline(user.screen_name).first(@tweets_per_person).map(&:text)
      most_recent_texts = client.user_timeline(user.screen_name, :count => @tweets_per_person).map(&:text)
      # Rails.logger.debug("Tweets#get_tweets_of_friends - friend user: |#{user.inspect}|")
      # Rails.logger.debug("Tweets#get_tweets_of_friends - screen_name = #{user.screen_name}")
      # Rails.logger.debug("Tweets#get_tweets_of_friends - user.profile_image_url.display_uri = #{user.profile_image_url.display_uri}")
      # Rails.logger.debug("Most recent text = most_recent_texts.inspect")
      {:name => user.name, :profile_image_link => user.profile_image_url.display_uri.to_s, :screen_name => user.screen_name, :most_recent_texts => most_recent_texts }
    end
    friend_tweets.compact!

    friend_tweets
  end



  def self.filter_out_non_tribal(all_friends, tribal_friends)
    subset_of_friends = nil
    return all_friends if tribal_friends.blank?

    unless all_friends.blank?
      subset_of_friends = all_friends.select{|f| tribal_friends.include?(f[:screen_name]) }
    end

    subset_of_friends
  end


  # remove people that are temporarily "prisoners", people whose tweets we do not want to see
  def self.filter_out_prisoners(all_friends, prisoners)
    subset_of_friends = nil

    return all_friends if prisoners.blank?

    unless all_friends.blank?
      subset_of_friends = all_friends.reject{|f| prisoners.include?(f[:screen_name]) }
    end

    subset_of_friends
  end


  def self.prisoner_picture_links(user_friends, prisoners)
    prisoner_names = prisoners.keys
    return nil if prisoners.blank?
    return nil if user_friends.blank?

    user_friends.each do |f|
      if prisoner_names.include? f[:screen_name]
        prisoners[f[:screen_name]] = f[:profile_image_link]
      end
    end
  end

end

