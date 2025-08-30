class InvoiceService
  attr_reader :search_service, :export_service, :validation_service

  def initialize(search_service: InvoiceSearchService.new,
                 export_service: InvoiceExportService.new,
                 validation_service: InvoiceValidationService.new)
    @search_service = search_service
    @export_service = export_service
    @validation_service = validation_service
  end

  def search_invoices(params = {})
    search_service.search(params)
  end

  def find_invoice_by_number(number)
    search_service.find_by_number(number)
  end

  def paginated_search(params = {}, page: 1, per_page: 20)
    search_service.paginated_search(params, page: page, per_page: per_page)
  end

  def get_pagination_metadata(collection)
    search_service.get_pagination_metadata(collection)
  end

  def validate_search_params(params)
    validation_service.validate_search_params(params)
  end

  def export_to_csv(params = {})
    export_service.export_to_csv(params)
  end
end
