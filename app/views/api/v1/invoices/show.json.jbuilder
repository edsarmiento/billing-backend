json.invoice do
  json.id @invoice.id
  json.invoice_number @invoice.invoice_number
  json.total @invoice.total
  json.formatted_total @invoice.formatted_total
  json.invoice_date @invoice.invoice_date
  json.formatted_date @invoice.formatted_date
  json.formatted_datetime @invoice.invoice_date.strftime("%B %d, %Y at %I:%M %p")
  json.short_date @invoice.short_date
  json.month_year @invoice.invoice_date.strftime("%B %Y")
  json.status @invoice.status
  json.active @invoice.active
  json.active_status_text @invoice.active? ? "Active" : "Inactive"
  json.active_status_class @invoice.active? ? "text-success" : "text-muted"

  # Status badge information
  json.status_badge_class case @invoice.status
  when "Vigente" then "badge-success"
  when "Pagada" then "badge-primary"
  when "Vencida" then "badge-warning"
  else "badge-secondary"
  end

  json.status_icon case @invoice.status
  when "Vigente" then "check-circle"
  when "Pagada" then "check-double"
  when "Vencida" then "exclamation-triangle"
  else "question-circle"
  end

  # Amount categorization
  json.amount_category case @invoice.total.to_f
  when 0..15 then "low"
  when 15..25 then "medium"
  else "high"
  end

  json.amount_category_class case @invoice.total.to_f
  when 0..15 then "text-success"
  when 15..25 then "text-warning"
  else "text-danger"
  end

  json.days_since_created (Date.current - @invoice.invoice_date.to_date).to_i
  json.vigente @invoice.vigente?
end
