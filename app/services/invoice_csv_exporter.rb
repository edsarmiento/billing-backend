require 'csv'

class InvoiceCsvExporter
  def export(invoices)
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
end
