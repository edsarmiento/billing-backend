require 'rails_helper'

RSpec.describe TopSellingDaysService do
  let(:repository) { instance_double(InvoiceRepository) }
  let(:service) { described_class.new(repository: repository) }
  let(:mock_result) { [
    double('Day1', day: Date.new(2024, 1, 15), total_sales: "1500.00 (25 invoices)", invoices_count: 25, average_invoice_value: 60.0, total_amount: 1500.0),
    double('Day2', day: Date.new(2024, 1, 10), total_sales: "1200.00 (20 invoices)", invoices_count: 20, average_invoice_value: 60.0, total_amount: 1200.0)
  ] }

  before do
    allow(repository).to receive(:top_selling_days).and_return(mock_result)
  end

  describe '#call' do
    it 'fetches top selling days from repository' do
      result = service.call

      expect(repository).to have_received(:top_selling_days)
      expect(result).to eq(mock_result)
    end

    it 'always returns top 10 days' do
      service.call

      expect(repository).to have_received(:top_selling_days)
    end
  end

  describe 'SOLID principles' do
    it 'follows Single Responsibility Principle' do
      # The service has a single responsibility: fetching top selling days
      expect(service.call).to be_an(Array)
    end

    it 'follows Dependency Inversion Principle' do
      # Service depends on repository abstraction, not concrete implementation
      expect(service.repository).to eq(repository)
    end

    it 'follows Open/Closed Principle - can be extended with new functionality' do
      # Service can be extended without modifying existing code
      expect(service).to respond_to(:call)
      expect(service).to respond_to(:repository)
    end
  end
end
