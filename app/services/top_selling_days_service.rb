class TopSellingDaysService
  attr_reader :repository

  def initialize
    @repository = InvoiceRepository.new
  end

  def call
    Rails.logger.info "TopSellingDaysService: Fetching top selling days"
    top_selling_days = repository.top_selling_days
    
    begin
      TopSellingDaysMailer.report_email('edst83@gmail.com', top_selling_days).deliver_now
      Rails.logger.info "TopSellingDaysService: Email report sent successfully"
    rescue => e
      Rails.logger.error "TopSellingDaysService: Failed to send email report - #{e.message}"
      # Don't raise the error, just log it so the service continues to work
    end
    
    top_selling_days
  end
end
