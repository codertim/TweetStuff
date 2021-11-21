
class RedisServer
  # note: not a typical model based on ActiveRecord

  def self.url
    url = nil

    if REDIS_SERVER == "localhost"
      url = "redis://#{REDIS_USERNAME}:#{REDIS_PASSWORD}@#{REDIS_SERVER}:#{REDIS_PORT}"
    else
      url = "redis://#{REDIS_USERNAME}:#{REDIS_PASSWORD}@#{REDIS_SERVER}.redistogo.com:#{REDIS_PORT}"
    end

    url
  end


  def self.redis_api(uri)
    api = nil

    if REDIS_SERVER == "localhost"
      api = Redis.new(:host => uri.host, :port => uri.port)
    else
      api = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    end

    api
  end
end

