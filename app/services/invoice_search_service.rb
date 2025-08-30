class InvoiceSearchService
  attr_reader :repository

  def initialize(repository: InvoiceRepository.new)
    @repository = repository
  end

  def search(params = {})
    repository.search(params)
  end

  def find_by_number(number)
    repository.find_by_invoice_number(number)
  end

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
end
