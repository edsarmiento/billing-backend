require 'rails_helper'

RSpec.describe TopSellingDaysService do
  let(:service) { described_class.new }
  let(:mock_result) { [
    { 'day' => Date.new(2024, 1, 15), 'invoices_count' => 25, 'average_invoice_value' => 60.0, 'total_amount' => 1500.0 },
    { 'day' => Date.new(2024, 1, 10), 'invoices_count' => 20, 'average_invoice_value' => 60.0, 'total_amount' => 1200.0 }
  ] }

  before do
    allow(InvoiceRepository).to receive(:new).and_return(
      double('InvoiceRepository', top_selling_days: mock_result)
    )
    allow(TopSellingDaysMailer).to receive(:report_email).and_return(
      double('Mailer', deliver_now: true)
    )
  end

  describe '#call' do
    it 'fetches top selling days from repository' do
      result = service.call

      expect(InvoiceRepository).to have_received(:new)
      expect(result).to eq(mock_result)
    end

    it 'always returns top 10 days' do
      result = service.call
      
      expect(InvoiceRepository).to have_received(:new)
      expect(result).to eq(mock_result)
    end

    it 'sends email report with the data' do
      service.call

      expect(TopSellingDaysMailer).to have_received(:report_email).with(ENV["EMAIL_TO"], mock_result)
    end
  end

  describe 'SOLID principles' do
    it 'follows Single Responsibility Principle' do
      expect(service.class.instance_methods(false)).to contain_exactly(:call, :repository)
    end

    it 'follows Dependency Inversion Principle' do
      expect(service.repository).to respond_to(:top_selling_days)
      
      other_repo = double('OtherRepository')
      allow(InvoiceRepository).to receive(:new).and_return(other_repo)
      allow(other_repo).to receive(:top_selling_days).and_return([])
      
      other_service = described_class.new
      expect(other_service.repository).to eq(other_repo)
    end

    it 'follows Open/Closed Principle - can be extended with new functionality' do
      expect(service).to respond_to(:call)
      expect(service).to respond_to(:repository)
      
      extended_service = Class.new(described_class) do
        def additional_method
          'extended functionality'
        end
      end.new
      
      expect(extended_service).to respond_to(:call)
      expect(extended_service).to respond_to(:additional_method)
    end
  end
end
