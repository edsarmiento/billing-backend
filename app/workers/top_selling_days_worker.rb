class TopSellingDaysWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3, backtrace: true

  def perform
    timestamp = Time.current
    puts "🚀 TopSellingDaysWorker called at #{timestamp} (UTC)"
    Rails.logger.info "🚀 TopSellingDaysWorker called at #{timestamp} (UTC)"
    
    begin
      service = TopSellingDaysService.new
      result = service.call
      
      puts "✅ TopSellingDaysWorker completed successfully at #{Time.current} (UTC)"
      puts "📊 Found #{result.count} top selling days"
      Rails.logger.info "✅ TopSellingDaysWorker completed successfully at #{Time.current} (UTC)"
      Rails.logger.info "📊 Found #{result.count} top selling days"
      
      # Log the top 3 results for monitoring
      result.first(3).each_with_index do |day, index|
        log_message = "Top #{index + 1}: #{day['day']} - #{day['invoices_count']} invoices, Total: $#{day['total_amount'].to_f.round(2)}"
        puts "📈 #{log_message}"
        Rails.logger.info "📈 #{log_message}"
      end
      
    rescue => e
      error_message = "❌ TopSellingDaysWorker failed at #{Time.current} (UTC): #{e.message}"
      puts error_message
      Rails.logger.error error_message
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end
end
