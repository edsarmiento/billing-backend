class InvoiceRepository < BaseRepository
  def initialize
    super(Invoice)
  end

  def search(params = {})
    cache_key = "invoices_search_#{params.to_json}"

    Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      invoices = model.all

      if params[:invoice_number].present?
        invoices = invoices.where("invoice_number ILIKE ?", "%#{params[:invoice_number]}%")
      end

      if params[:status].present?
        invoices = invoices.where(status: params[:status])
      end

      if params[:date_from].present?
        invoices = invoices.where("invoice_date >= ?", params[:date_from])
      end

      if params[:date_to].present?
        invoices = invoices.where("invoice_date <= ?", params[:date_to])
      end

      if params[:min_amount].present?
        invoices = invoices.where("total >= ?", params[:min_amount])
      end

      if params[:max_amount].present?
        invoices = invoices.where("total <= ?", params[:max_amount])
      end

      if params[:active].present?
        invoices = params[:active] == "true" ? invoices.active : invoices.inactive
      end

      invoices.recent
    end
  end

  def find_by_invoice_number(number)
    Rails.cache.fetch("invoice_number_#{number}", expires_in: 1.hour) do
      model.find_by(invoice_number: number)
    end
  end

  def by_status(status)
    Rails.cache.fetch("invoices_status_#{status}", expires_in: 30.minutes) do
      model.where(status: status)
    end
  end

  def vigente
    Rails.cache.fetch("invoices_vigente", expires_in: 30.minutes) do
      model.where(status: "Vigente")
    end
  end

  def by_date_range(start_date, end_date)
    cache_key = "invoices_date_range_#{start_date}_#{end_date}"
    Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      model.where(invoice_date: start_date..end_date)
    end
  end

  def by_month(year, month)
    cache_key = "invoices_month_#{year}_#{month}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      model.where("EXTRACT(YEAR FROM invoice_date) = ? AND EXTRACT(MONTH FROM invoice_date) = ?", year, month)
    end
  end

  def by_year(year)
    Rails.cache.fetch("invoices_year_#{year}", expires_in: 1.hour) do
      model.where("EXTRACT(YEAR FROM invoice_date) = ?", year)
    end
  end

  def high_value
    Rails.cache.fetch("invoices_high_value", expires_in: 30.minutes) do
      model.where("total > ?", 20.0)
    end
  end

  def low_value
    Rails.cache.fetch("invoices_low_value", expires_in: 30.minutes) do
      model.where("total <= ?", 20.0)
    end
  end

  def active
    Rails.cache.fetch("invoices_active", expires_in: 30.minutes) do
      model.active
    end
  end

  def inactive
    Rails.cache.fetch("invoices_inactive", expires_in: 30.minutes) do
      model.inactive
    end
  end

  def to_csv(options = {})
    require "csv"

    Enumerator.new do |yielder|
      yielder << CSV.generate_line([ "ID", "Invoice Number", "Total", "Date", "Status", "Active" ])

      model.find_in_batches(batch_size: 1000) do |batch|
        batch.each do |invoice|
          yielder << CSV.generate_line([
            invoice.id,
            invoice.invoice_number,
            invoice.total,
            invoice.invoice_date,
            invoice.status,
            invoice.active
          ])
        end
      end
    end
  end

  def paginated(page: 1, per_page: 20)
    model.recent.page(page).per(per_page)
  end

  def search_paginated(params = {}, page: 1, per_page: 20)
    search(params).page(page).per(per_page)
  end

  def count_with_cache
    Rails.cache.fetch("invoices_count", expires_in: 5.minutes) do
      model.count
    end
  end

  def total_amount_with_cache
    Rails.cache.fetch("invoices_total_amount", expires_in: 5.minutes) do
      model.sum(:total)
    end
  end
end
