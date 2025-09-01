require 'rails_helper'

RSpec.describe InvoiceService do
  let(:search_service) { instance_double(InvoiceSearchService) }
  let(:export_service) { instance_double(InvoiceExportService) }
  let(:validation_service) { instance_double(InvoiceValidationService) }
  let(:service) { described_class.new(search_service: search_service, export_service: export_service, validation_service: validation_service) }

  describe '#search_invoices' do
    let(:params) { { status: 'Vigente' } }
    # Use real data from the read-only database
    let(:real_invoices) { Invoice.where(status: 'Vigente').limit(2) }

    before do
      allow(search_service).to receive(:search).with(params).and_return(real_invoices)
    end

    it 'delegates to search service' do
      result = service.search_invoices(params)
      expect(search_service).to have_received(:search).with(params)
      expect(result).to eq(real_invoices)
    end
  end

  describe '#find_invoice_by_number' do
    # Use real invoice data from the database
    let(:real_invoice) { Invoice.first }
    let(:invoice_number) { real_invoice.invoice_number }

    before do
      allow(search_service).to receive(:find_by_number).with(invoice_number).and_return(real_invoice)
    end

    it 'delegates to search service' do
      result = service.find_invoice_by_number(invoice_number)
      expect(search_service).to have_received(:find_by_number).with(invoice_number)
      expect(result).to eq(real_invoice)
    end
  end

  describe '#paginated_search' do
    let(:params) { { status: 'Vigente' } }
    let(:paginated_invoices) { double('PaginatedInvoices') }

    before do
      allow(search_service).to receive(:paginated_search).with(params, page: 2, per_page: 10).and_return(paginated_invoices)
    end

    it 'delegates to search service with pagination' do
      result = service.paginated_search(params, page: 2, per_page: 10)
      expect(search_service).to have_received(:paginated_search).with(params, page: 2, per_page: 10)
      expect(result).to eq(paginated_invoices)
    end

    it 'uses default pagination when not specified' do
      allow(search_service).to receive(:paginated_search).with(params, page: 1, per_page: 20).and_return(paginated_invoices)
      service.paginated_search(params)
      expect(search_service).to have_received(:paginated_search).with(params, page: 1, per_page: 20)
    end
  end

  describe '#get_pagination_metadata' do
    let(:collection) do
      double('PaginatedCollection',
             current_page: 2,
             total_pages: 5,
             total_count: 100,
             limit_value: 20)
    end

    it 'returns pagination metadata' do
      allow(search_service).to receive(:get_pagination_metadata).with(collection).and_return({
        current_page: 2,
        total_pages: 5,
        total_count: 100,
        per_page: 20
      })

      result = service.get_pagination_metadata(collection)
      expect(search_service).to have_received(:get_pagination_metadata).with(collection)
      expect(result).to eq({
        current_page: 2,
        total_pages: 5,
        total_count: 100,
        per_page: 20
      })
    end
  end

  describe '#validate_search_params' do
    let(:params) { { date_from: '2022-01-01', date_to: '2022-01-31' } }
    let(:errors) { [] }

    before do
      allow(validation_service).to receive(:validate_search_params).with(params).and_return(errors)
    end

    it 'delegates to validation service' do
      result = service.validate_search_params(params)
      expect(validation_service).to have_received(:validate_search_params).with(params)
      expect(result).to eq(errors)
    end

    context 'when validation fails' do
      let(:errors) { [ 'Invalid date format' ] }

      it 'returns validation errors' do
        result = service.validate_search_params(params)
        expect(validation_service).to have_received(:validate_search_params).with(params)
        expect(result).to eq(errors)
      end
    end
  end

  describe '#export_to_csv' do
    let(:params) { { status: 'Vigente' } }
    let(:csv_data) { "ID,Invoice Number,Total\n1,C30001,25.50" }

    before do
      allow(export_service).to receive(:export_to_csv).with(params).and_return(csv_data)
    end

    it 'exports filtered invoices when params provided' do
      result = service.export_to_csv(params)
      expect(export_service).to have_received(:export_to_csv).with(params)
      expect(result).to eq(csv_data)
    end

    context 'when no params provided' do
      it 'exports all invoices' do
        allow(export_service).to receive(:export_to_csv).with({}).and_return(csv_data)
        result = service.export_to_csv
        expect(export_service).to have_received(:export_to_csv).with({})
        expect(result).to eq(csv_data)
      end
    end
  end

  describe 'dependency injection' do
    it 'uses default dependencies when not provided' do
      service = described_class.new
      expect(service.search_service).to be_an_instance_of(InvoiceSearchService)
      expect(service.export_service).to be_an_instance_of(InvoiceExportService)
      expect(service.validation_service).to be_an_instance_of(InvoiceValidationService)
    end

    it 'allows custom dependencies' do
      custom_search = instance_double(InvoiceSearchService)
      custom_export = instance_double(InvoiceExportService)
      custom_validation = instance_double(InvoiceValidationService)

      service = described_class.new(
        search_service: custom_search,
        export_service: custom_export,
        validation_service: custom_validation
      )

      expect(service.search_service).to eq(custom_search)
      expect(service.export_service).to eq(custom_export)
      expect(service.validation_service).to eq(custom_validation)
    end
  end

  describe 'integration with real data' do
    context 'when working with real repository' do
      let(:real_service) { described_class.new }

      it 'can search real invoices' do
        # This test uses real data from the read-only database
        result = real_service.search_invoices({ status: 'Vigente' })
        expect(result).to be_an(ActiveRecord::Relation)
      end

      it 'can find real invoice by number' do
        # This test uses real data from the read-only database
        real_invoice = Invoice.first
        result = real_service.find_invoice_by_number(real_invoice.invoice_number)
        expect(result).to eq(real_invoice)
      end

      it 'validates real search parameters' do
        # This test uses real data from the read-only database
        result = real_service.validate_search_params({ status: 'Vigente' })
        expect(result).to be_an(Array)
      end
    end
  end
end
