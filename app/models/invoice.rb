require 'kaminari'

class Invoice < ApplicationRecord

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :recent, -> { order(invoice_date: :desc) }
  
  def formatted_total
    "$#{total.to_f.round(2)}"
  end

  def formatted_date
    invoice_date.strftime("%B %d, %Y")
  end

  def short_date
    invoice_date.strftime("%m/%d/%Y")
  end

  def formatted_datetime
    invoice_date.strftime("%B %d, %Y at %I:%M %p")
  end

  def month_year
    invoice_date.strftime("%B %Y")
  end

  def active?
    active
  end

  def vigente?
    status == 'Vigente'
  end

  def amount_category
    case total.to_f
    when 0..15
      'low'
    when 15..25
      'medium'
    else
      'high'
    end
  end

  def days_since_created
    (Date.current - invoice_date.to_date).to_i
  end

  def status_badge_class
    case status
    when 'Vigente'
      'badge-success'
    when 'Pagada'
      'badge-primary'
    when 'Vencida'
      'badge-warning'
    else
      'badge-secondary'
    end
  end
end
