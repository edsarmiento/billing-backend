class InvoiceService
  attr_reader :repository, :validator, :exporter

  def initialize(repository: InvoiceRepository.new, 
                 validator: InvoiceSearchValidator.new,
                 exporter: InvoiceCsvExporter.new)
    @repository = repository
    @validator = validator
    @exporter = exporter
  end

  # Single responsibility: Search invoices
  def search_invoices(params = {})
    repository.search(params)
  end

  def find_invoice_by_number(number)
    repository.find_by_invoice_number(number)
  end

  # Single responsibility: Pagination
  def paginated_search(params = {}, page: 1, per_page: 20)
    repository.search_paginated(params, page: page, per_page: per_page)
  end

  def get_pagination_metadata(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end

  # Single responsibility: Validation
  def validate_search_params(params)
    validator.validate(params)
  end

  # Single responsibility: Export
  def export_to_csv(params = {})
    invoices = params.empty? ? repository.all : repository.search(params)
    exporter.export(invoices)
  end
end
