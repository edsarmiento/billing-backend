# Simple caching configuration for the invoice consultation app

Rails.application.configure do
  # Use Redis for caching in production
  if Rails.env.production?
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_URL'] || 'redis://localhost:6379/1',
      expires_in: 1.hour
    }
  end
end
