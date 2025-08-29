class InvoiceService
  attr_reader :repository

  def initialize
    @repository = InvoiceRepository.new
  end

  # Search and filtering
  def search_invoices(params = {})
    repository.search(params)
  end

  def find_invoice_by_number(number)
    repository.find_by_invoice_number(number)
  end

  # Export functionality
  def export_to_csv(params = {})
    invoices = params.empty? ? repository.all : repository.search(params)
    
    CSV.generate do |csv|
      csv << ['ID', 'Invoice Number', 'Total', 'Date', 'Status', 'Active', 'Formatted Total']
      invoices.each do |invoice|
        csv << [
          invoice.id,
          invoice.invoice_number,
          invoice.total,
          invoice.invoice_date,
          invoice.status,
          invoice.active,
          invoice.formatted_total
        ]
      end
    end
  end

  # Validation and business rules
  def validate_search_params(params)
    errors = []
    
    if params[:date_from].present? && params[:date_to].present?
      begin
        date_from = Date.parse(params[:date_from])
        date_to = Date.parse(params[:date_to])
        
        if date_from > date_to
          errors << "Start date cannot be after end date"
        end
      rescue Date::Error
        errors << "Invalid date format"
      end
    end
    
    if params[:min_amount].present? && params[:max_amount].present?
      min_amount = params[:min_amount].to_f
      max_amount = params[:max_amount].to_f
      
      if min_amount > max_amount
        errors << "Minimum amount cannot be greater than maximum amount"
      end
    end
    
    errors
  end

  # Pagination helpers
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
