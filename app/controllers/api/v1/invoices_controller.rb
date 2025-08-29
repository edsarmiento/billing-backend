class Api::V1::InvoicesController < ApplicationController
  before_action :initialize_service
  before_action :set_cache_headers, only: [:index, :show, :search]

  def index
    validation_errors = @service.validate_search_params(params)
    if validation_errors.any?
      render json: { errors: validation_errors }, status: :bad_request
      return
    end

    @invoices = @service.paginated_search(params, page: params[:page] || 1, per_page: params[:per_page])
    @pagination = @service.get_pagination_metadata(@invoices)
    @search_params = params.permit(:invoice_number, :status, :date_from, :date_to, :min_amount, :max_amount, :active)

    response.headers['X-Total-Count'] = @pagination[:total_count].to_s
    response.headers['X-Page-Count'] = @pagination[:total_pages].to_s
  end

  def show
    @invoice = @service.find_invoice_by_number(params[:id])
    
    if @invoice.nil?
      render json: { error: 'Invoice not found' }, status: :not_found
    end
  end

  def search
    @invoices = @service.search_invoices(params)
    @search_params = params.permit(:invoice_number, :status, :date_from, :date_to, :min_amount, :max_amount, :active)
    
    # Add performance headers
    response.headers['X-Result-Count'] = @invoices.count.to_s
  end

  def export
    # Stream the CSV response for better performance
    csv_data = @service.export_to_csv(params)
    
    response.headers['Content-Type'] = 'text/csv'
    response.headers['Content-Disposition'] = "attachment; filename=invoices_#{Date.current.strftime('%Y%m%d')}.csv"
    
    # Stream the response
    self.response_body = csv_data
  end

  private

  def initialize_service
    @service = InvoiceService.new
  end

  def set_cache_headers
    # Set cache headers for better performance
    response.headers['Cache-Control'] = 'public, max-age=300' # 5 minutes
    response.headers['ETag'] = Digest::MD5.hexdigest(request.fullpath + params.to_json)
  end
end
