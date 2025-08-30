require 'rails_helper'

RSpec.describe InvoiceService do
  let(:repository) { instance_double(InvoiceRepository) }
  let(:validator) { instance_double(InvoiceSearchValidator) }
  let(:exporter) { instance_double(InvoiceCsvExporter) }
  let(:service) { described_class.new(repository: repository, validator: validator, exporter: exporter) }

  describe '#search_invoices' do
    let(:params) { { status: 'Vigente' } }
    # Use real data from the read-only database
    let(:real_invoices) { Invoice.where(status: 'Vigente').limit(2) }

    before do
      allow(repository).to receive(:search).with(params).and_return(real_invoices)
    end

    it 'delegates to repository' do
      result = service.search_invoices(params)
      expect(repository).to have_received(:search).with(params)
      expect(result).to eq(real_invoices)
    end
  end

  describe '#find_invoice_by_number' do
    # Use real invoice data from the database
    let(:real_invoice) { Invoice.first }
    let(:invoice_number) { real_invoice.invoice_number }

    before do
      allow(repository).to receive(:find_by_invoice_number).with(invoice_number).and_return(real_invoice)
    end

    it 'delegates to repository' do
      result = service.find_invoice_by_number(invoice_number)
      expect(repository).to have_received(:find_by_invoice_number).with(invoice_number)
      expect(result).to eq(real_invoice)
    end
  end

  describe '#paginated_search' do
    let(:params) { { status: 'Vigente' } }
    let(:paginated_invoices) { double('PaginatedInvoices') }

    before do
      allow(repository).to receive(:search_paginated).with(params, page: 2, per_page: 10).and_return(paginated_invoices)
    end

    it 'delegates to repository with pagination' do
      result = service.paginated_search(params, page: 2, per_page: 10)
      expect(repository).to have_received(:search_paginated).with(params, page: 2, per_page: 10)
      expect(result).to eq(paginated_invoices)
    end

    it 'uses default pagination when not specified' do
      allow(repository).to receive(:search_paginated).with(params, page: 1, per_page: 20).and_return(paginated_invoices)
      service.paginated_search(params)
      expect(repository).to have_received(:search_paginated).with(params, page: 1, per_page: 20)
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
      result = service.get_pagination_metadata(collection)
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
      allow(validator).to receive(:validate).with(params).and_return(errors)
    end

    it 'delegates to validator' do
      result = service.validate_search_params(params)
      expect(validator).to have_received(:validate).with(params)
      expect(result).to eq(errors)
    end

    context 'when validation fails' do
      let(:errors) { [ 'Invalid date format' ] }

      it 'returns validation errors' do
        result = service.validate_search_params(params)
        expect(result).to eq(errors)
      end
    end
  end

  describe '#export_to_csv' do
    let(:params) { { status: 'Vigente' } }
    # Use real data from the read-only database
    let(:real_invoices) { Invoice.where(status: 'Vigente').limit(2) }
    let(:csv_data) { "ID,Invoice Number,Total\n1,C30481,14.45\n" }

    before do
      allow(repository).to receive(:search).with(params).and_return(real_invoices)
      allow(exporter).to receive(:export).with(real_invoices).and_return(csv_data)
    end

    it 'exports filtered invoices when params provided' do
      result = service.export_to_csv(params)
      expect(repository).to have_received(:search).with(params)
      expect(exporter).to have_received(:export).with(real_invoices)
      expect(result).to eq(csv_data)
    end

    context 'when no params provided' do
      before do
        allow(repository).to receive(:all).and_return(real_invoices)
      end

      it 'exports all invoices' do
        result = service.export_to_csv({})
        expect(repository).to have_received(:all)
        expect(exporter).to have_received(:export).with(real_invoices)
        expect(result).to eq(csv_data)
      end
    end
  end

  describe 'dependency injection' do
    it 'uses default dependencies when not provided' do
      service = described_class.new
      expect(service.repository).to be_an_instance_of(InvoiceRepository)
      expect(service.validator).to be_an_instance_of(InvoiceSearchValidator)
      expect(service.exporter).to be_an_instance_of(InvoiceCsvExporter)
    end

    it 'allows custom dependencies' do
      custom_repository = instance_double(InvoiceRepository)
      custom_validator = instance_double(InvoiceSearchValidator)
      custom_exporter = instance_double(InvoiceCsvExporter)

      service = described_class.new(
        repository: custom_repository,
        validator: custom_validator,
        exporter: custom_exporter
      )

      expect(service.repository).to eq(custom_repository)
      expect(service.validator).to eq(custom_validator)
      expect(service.exporter).to eq(custom_exporter)
    end
  end

  # Integration tests with real data
  describe 'integration with real data' do
    let(:real_service) { described_class.new }

    context 'when working with real repository' do
      it 'can search real invoices' do
        # This test will actually query the read-only database
        result = real_service.search_invoices({ status: 'Vigente' })
        expect(result).to be_a(ActiveRecord::Relation)
      end

      it 'can find real invoice by number' do
        real_invoice = Invoice.first
        result = real_service.find_invoice_by_number(real_invoice.invoice_number)
        expect(result).to eq(real_invoice)
      end

      it 'validates real search parameters' do
        result = real_service.validate_search_params({ date_from: 'invalid-date' })
        expect(result).to be_an(Array)
      end
    end
  end
end
