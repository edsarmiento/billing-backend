# Simple caching configuration for the invoice consultation app

Rails.application.configure do
  # Configure Redis caching using centralized Redis configuration
  config.cache_store = :redis_cache_store, {
    url: RedisConfig.url,
    expires_in: 1.hour,
    reconnect_attempts: 3,
    reconnect_delay: 0.5,
    reconnect_delay_max: 2.0
  }
end
