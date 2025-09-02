namespace :worker do
  desc "Run TopSellingDaysWorker manually"
      task top_selling_days: :environment do
      puts "🚀 Queuing TopSellingDaysWorker to run in background..."
      job_id = TopSellingDaysWorker.perform_async
      puts "✅ TopSellingDaysWorker queued successfully with job ID: #{job_id}"
      puts "📋 Check Sidekiq dashboard or logs to monitor progress"
    end
end
