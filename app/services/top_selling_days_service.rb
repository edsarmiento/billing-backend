class TopSellingDaysService
  attr_reader :repository

  def initialize()
    @repository = InvoiceRepository.new
  end

  def call
    repository.top_selling_days
  end
end
