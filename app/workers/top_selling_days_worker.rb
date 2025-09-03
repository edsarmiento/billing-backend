class TopSellingDaysWorker
  include Sidekiq::Worker
  
  # Set longer timeout for email sending
  sidekiq_options timeout: 60

  def perform
    Rails.logger.info "🚀 TopSellingDaysWorker called at #{Time.current.utc} (UTC)"

    begin
      service = TopSellingDaysService.new
      result = service.call

      Rails.logger.info "✅ TopSellingDaysWorker completed successfully at #{Time.current.utc} (UTC)"
      Rails.logger.info "📊 Found #{result.count} top selling days"

      # Log the top 3 results for monitoring
      result.first(3).each_with_index do |day, i|
        Rails.logger.info "📈 Top #{i+1}: #{day['day']} - #{day['invoices_count']} invoices, Total: $#{day['total_amount']}"
      end

    rescue => e
      Rails.logger.error "❌ TopSellingDaysWorker: Error calculating top selling days: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
