Rails.application.config.middleware.use OmniAuth::Builder do  
  # provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  # Heroku advises env. variables or storing on S3 since their filesystem is read-only
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end  
