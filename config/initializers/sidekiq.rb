require "sidekiq"

Sidekiq.configure_server do |config|
  redis_url = ENV["REDIS_URL"] || "redis://localhost:6379/0"
  
  # Try to parse Redis URL and handle authentication
  begin
    uri = URI.parse(redis_url)
    redis_config = {
      host: uri.host,
      port: uri.port,
      db: uri.path&.gsub('/', '')&.to_i || 0
    }
    
    # If there's a password in the URL, use it
    if uri.password
      redis_config[:password] = uri.password
    end
    
    config.redis = redis_config
  rescue => e
    # Fallback to URL if parsing fails
    config.redis = { url: redis_url }
  end

  # Configure logging
  config.logger.level = Logger::INFO

  # Configure concurrency
  config.concurrency = ENV.fetch("SIDEKIQ_CONCURRENCY", 5).to_i
end

Sidekiq.configure_client do |config|
  redis_url = ENV["REDIS_URL"] || "redis://localhost:6379/0"
  
  # Try to parse Redis URL and handle authentication
  begin
    uri = URI.parse(redis_url)
    redis_config = {
      host: uri.host,
      port: uri.port,
      db: uri.path&.gsub('/', '')&.to_i || 0
    }
    
    # If there's a password in the URL, use it
    if uri.password
      redis_config[:password] = uri.password
    end
    
    config.redis = redis_config
  rescue => e
    # Fallback to URL if parsing fails
    config.redis = { url: redis_url }
  end
end
