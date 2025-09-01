class TopSellingDaysMailer < ApplicationMailer
  def report_email(email, top_selling_days_data)
    @top_selling_days = top_selling_days_data
    @generated_at = Time.current
    
    # Set Spanish locale for proper date formatting
    I18n.with_locale(:es) do
      mail(
        to: email,
        subject: "Reporte de Días con Mayor Venta - #{@generated_at.strftime('%d/%m/%Y')}"
      )
    end
  end
end
