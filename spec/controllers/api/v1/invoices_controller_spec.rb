require 'rails_helper'

RSpec.describe Api::V1::InvoicesController, type: :controller do
  let(:service) { instance_double(InvoiceService) }
  let(:repository) { instance_double(InvoiceRepository) }
  let(:validator) { instance_double(InvoiceSearchValidator) }
  let(:exporter) { instance_double(InvoiceCsvExporter) }

  before do
    allow(InvoiceService).to receive(:new).and_return(service)
    allow(service).to receive(:repository).and_return(repository)
    allow(service).to receive(:validator).and_return(validator)
    allow(service).to receive(:exporter).and_return(exporter)
  end

  describe 'GET #index' do
    # Use real data from the read-only database
    let(:real_invoices) { Invoice.limit(3) }
    let(:paginated_invoices) { double('PaginatedInvoices', current_page: 1, total_pages: 1, total_count: real_invoices.count, limit_value: 20) }
    let(:pagination_metadata) { { current_page: 1, total_pages: 1, total_count: real_invoices.count, per_page: 20 } }

    before do
      allow(service).to receive(:paginated_search).and_return(paginated_invoices)
      allow(service).to receive(:get_pagination_metadata).and_return(pagination_metadata)
      allow(service).to receive(:validate_search_params).and_return([])
      allow(service).to receive(:search_invoices).and_return(real_invoices)
    end

    context 'with pagination parameters' do
      it 'returns paginated response' do
        get :index, params: { page: 1, per_page: 20 }, format: :json
        expect(service).to have_received(:paginated_search).with({ "page" => "1", "per_page" => "20" }, page: 1, per_page: 20)
        expect(response.headers['X-Total-Count']).to eq(real_invoices.count.to_s)
        expect(response.headers['X-Page-Count']).to eq('1')
      end

      it 'includes pagination metadata' do
        get :index, params: { page: 1, per_page: 20 }, format: :json
        expect(assigns(:pagination)).to eq(pagination_metadata)
      end
    end

    context 'without pagination parameters' do
      it 'returns all results without pagination' do
        get :index, format: :json
        expect(service).to have_received(:search_invoices).with({})
        expect(response.headers['X-Result-Count']).to eq(real_invoices.count.to_s)
        expect(response.headers['X-Total-Count']).to be_nil
        expect(response.headers['X-Page-Count']).to be_nil
      end
    end

    context 'with search parameters' do
      let(:search_params) { { status: 'Vigente', page: 2, per_page: 10 } }

      it 'passes search parameters to service with pagination' do
        get :index, params: search_params, format: :json
        expect(service).to have_received(:paginated_search).with({ "status" => "Vigente", "page" => "2", "per_page" => "10" }, page: 2, per_page: 10)
      end

      it 'passes search parameters without pagination' do
        search_params_no_pagination = { status: 'Vigente' }
        get :index, params: search_params_no_pagination, format: :json
        expect(service).to have_received(:search_invoices).with({ "status" => "Vigente" })
      end
    end

    context 'with invalid parameters' do
      before do
        allow(service).to receive(:validate_search_params).and_return(['Invalid date format'])
      end

      it 'returns bad request status' do
        get :index, params: { date_from: 'invalid-date' }, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns validation errors' do
        get :index, params: { date_from: 'invalid-date' }, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Invalid date format')
      end
    end
  end

  describe 'GET #show' do
    # Use real invoice data from the database
    let(:real_invoice) { Invoice.first }

    context 'when invoice exists' do
      before do
        allow(service).to receive(:find_invoice_by_number).with(real_invoice.invoice_number).and_return(real_invoice)
      end

      it 'returns a successful response' do
        get :show, params: { id: real_invoice.invoice_number }, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'assigns the invoice' do
        get :show, params: { id: real_invoice.invoice_number }, format: :json
        expect(assigns(:invoice)).to eq(real_invoice)
      end
    end

    context 'when invoice does not exist' do
      before do
        allow(service).to receive(:find_invoice_by_number).with('INVALID').and_return(nil)
      end

      it 'returns not found status' do
        get :show, params: { id: 'INVALID' }, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        get :show, params: { id: 'INVALID' }, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invoice not found')
      end
    end
  end

  describe 'GET #export' do
    let(:csv_data) { "ID,Invoice Number,Total,Date,Status,Active,Formatted Total\n1,C30481,14.45,2022-01-17,Vigente,true,$14.45\n" }

    before do
      allow(service).to receive(:export_to_csv).and_return(csv_data)
    end

    it 'returns a successful response' do
      get :export, format: :csv
      expect(response).to have_http_status(:ok)
    end

    it 'sets correct content type' do
      get :export, format: :csv
      expect(response.content_type).to include('text/csv')
    end

    it 'sets correct filename' do
      get :export, format: :csv
      expect(response.headers['Content-Disposition']).to include('attachment')
      expect(response.headers['Content-Disposition']).to include('invoices_')
      expect(response.headers['Content-Disposition']).to include('.csv')
    end

    it 'exports with parameters' do
      export_params = { status: 'Vigente' }
      get :export, params: export_params, format: :csv
      expect(service).to have_received(:export_to_csv).with({ "status" => "Vigente" })
    end

    it 'streams CSV data' do
      get :export, format: :csv
      expect(response.body).to eq(csv_data)
    end
  end

  describe 'private methods' do
    describe '#set_cache_headers' do
      let(:paginated_invoices) { double('PaginatedInvoices', current_page: 1, total_pages: 1, total_count: 3, limit_value: 20) }
      let(:pagination_metadata) { { current_page: 1, total_pages: 1, total_count: 3, per_page: 20 } }

      before do
        allow(service).to receive(:validate_search_params).and_return([])
        allow(service).to receive(:paginated_search).and_return(paginated_invoices)
        allow(service).to receive(:get_pagination_metadata).and_return(pagination_metadata)
        allow(service).to receive(:search_invoices).and_return([])
      end

      it 'sets cache control headers' do
        get :index, format: :json
        expect(response.headers['Cache-Control']).to include('public')
        expect(response.headers['Cache-Control']).to include('max-age=300')
      end

      it 'sets ETag header' do
        get :index, format: :json
        expect(response.headers['ETag']).to be_present
      end
    end

    describe '#pagination_requested?' do
      it 'returns true when page parameter is present' do
        params = { page: '1' }
        expect(controller.send(:pagination_requested?, params)).to be true
      end

      it 'returns true when per_page parameter is present' do
        params = { per_page: '20' }
        expect(controller.send(:pagination_requested?, params)).to be true
      end

      it 'returns false when no pagination parameters are present' do
        params = { status: 'Vigente' }
        expect(controller.send(:pagination_requested?, params)).to be false
      end
    end
  end
end
