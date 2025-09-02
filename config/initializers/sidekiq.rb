require "sidekiq"
require "sidekiq-cron"

# Configure Sidekiq
Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379/0" }
  
  # Set longer timeout for jobs to handle email sending
  config.timeout = 120  # 2 minutes total timeout
  config.death_handlers << ->(job, ex) do
    Sidekiq.logger.error "Job #{job['class']} failed: #{ex.message}"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379/0" }
end

# Schedule cron jobs
schedule_file = Rails.root.join("config", "sidekiq_cron.yml")

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
