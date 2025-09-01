class TopSellingDaysService
  attr_reader :repository

  def initialize
    @repository = InvoiceRepository.new
  end

  def call
    Rails.logger.info "TopSellingDaysService: Fetching top selling days"
    repository.top_selling_days
  end
end
