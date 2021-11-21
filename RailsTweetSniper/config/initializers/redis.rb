
REDIS_PASSWORD = ENV['REDIS_PASSWORD'] || 'None'
REDIS_PORT     = ENV['REDIS_PORT']     || 6379
REDIS_SERVER   = ENV['REDIS_SERVER']   || "localhost"
REDIS_USERNAME = ENV['REDIS_USERNAME'] || 'None'

puts "Initializer - Redis Configuration:"
puts "  REDIS_SERVER: #{REDIS_SERVER} "
puts "  REDIS_PORT:   #{REDIS_PORT} "


