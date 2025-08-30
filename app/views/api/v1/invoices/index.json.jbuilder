json.invoices @invoices do |invoice|
  json.id invoice.id
  json.invoice_number invoice.invoice_number
  json.total invoice.total
  json.formatted_total invoice.formatted_total
  json.invoice_date invoice.invoice_date
  json.formatted_date invoice.formatted_date
  json.short_date invoice.short_date
  json.status invoice.status
  json.active invoice.active
  json.active_status_text invoice.active? ? "Active" : "Inactive"
  json.active_status_class invoice.active? ? "text-success" : "text-muted"

  # Status badge information
  json.status_badge_class case invoice.status
  when "Vigente" then "badge-success"
  when "Pagada" then "badge-primary"
  when "Vencida" then "badge-warning"
  else "badge-secondary"
  end

  json.status_icon case invoice.status
  when "Vigente" then "check-circle"
  when "Pagada" then "check-double"
  when "Vencida" then "exclamation-triangle"
  else "question-circle"
  end

  # Amount categorization
  json.amount_category case invoice.total.to_f
  when 0..15 then "low"
  when 15..25 then "medium"
  else "high"
  end

  json.amount_category_class case invoice.total.to_f
  when 0..15 then "text-success"
  when 15..25 then "text-warning"
  else "text-danger"
  end

  json.days_since_created (Date.current - invoice.invoice_date.to_date).to_i
end

# Pagination metadata
if @pagination
  json.pagination do
    json.current_page @pagination[:current_page]
    json.total_pages @pagination[:total_pages]
    json.total_count @pagination[:total_count]
    json.per_page @pagination[:per_page]
  end
end

# Search metadata
if @search_params
  json.search_params @search_params
end
