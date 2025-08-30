class InvoiceExportService
  attr_reader :repository, :exporter

  def initialize(repository: InvoiceRepository.new, exporter: InvoiceCsvExporter.new)
    @repository = repository
    @exporter = exporter
  end

  def export_to_csv(params = {})
    invoices = params.empty? ? repository.all : repository.search(params)
    exporter.export(invoices)
  end
end
