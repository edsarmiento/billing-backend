class Api::V1::InvoicesController < ApplicationController
  before_action :initialize_service
  before_action :set_cache_headers, only: [:index, :show]

  def index
    search_params = params.permit(:invoice_number, :status, :date_from, :date_to, :min_amount, :max_amount, :active, :page, :per_page).to_h
    validation_errors = @service.validate_search_params(search_params)
    if validation_errors.any?
      render json: { errors: validation_errors }, status: :bad_request
      return
    end

    # Check if pagination is requested
    if pagination_requested?(search_params)
      # Paginated response
      @invoices = @service.paginated_search(search_params, page: (params[:page] || 1).to_i, per_page: params[:per_page]&.to_i)
      @pagination = @service.get_pagination_metadata(@invoices)
      @search_params = search_params

      response.headers['X-Total-Count'] = @pagination[:total_count].to_s
      response.headers['X-Page-Count'] = @pagination[:total_pages].to_s
    else
      # Non-paginated response (all results)
      @invoices = @service.search_invoices(search_params)
      @search_params = search_params
      
      response.headers['X-Result-Count'] = @invoices.count.to_s
    end
  end

  def show
    @invoice = @service.find_invoice_by_number(params[:id])
    
    if @invoice.nil?
      render json: { error: 'Invoice not found' }, status: :not_found
    end
  end

  def export
    # Stream the CSV response for better performance
    export_params = params.permit(:invoice_number, :status, :date_from, :date_to, :min_amount, :max_amount, :active).to_h
    csv_data = @service.export_to_csv(export_params)
    
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

  def pagination_requested?(params)
    # Check if pagination parameters are present
    params[:page].present? || params[:per_page].present?
  end
end
