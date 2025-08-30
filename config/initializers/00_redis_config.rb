# Redis configuration helper
module RedisConfig
  def self.url
    if Rails.env.production?
      # Production: Use Railway's Redis URL
      ENV['REDIS_URL'] || ENV['RAILWAY_REDIS_URL'] || 'redis://localhost:6379/1'
    else
      # Development: Use Docker Compose Redis
      ENV['REDIS_URL'] || 'redis://redis:6379/1'
    end
  end

  def self.log_configuration
    Rails.logger.info "Redis configured for #{Rails.env} environment"
    Rails.logger.info "Redis URL: #{url}"
  end
end

# Log Redis configuration on startup
Rails.application.config.after_initialize do
  RedisConfig.log_configuration
end
