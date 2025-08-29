class InvoiceSearchValidator
  def validate(params)
    errors = []
    
    validate_date_range(params, errors)
    validate_amount_range(params, errors)
    
    errors
  end

  private

  def validate_date_range(params, errors)
    if params[:date_from].present? && params[:date_to].present?
      begin
        date_from = Date.parse(params[:date_from])
        date_to = Date.parse(params[:date_to])
        
        if date_from > date_to
          errors << "Start date cannot be after end date"
        end
      rescue Date::Error
        errors << "Invalid date format"
      end
    end
  end

  def validate_amount_range(params, errors)
    if params[:min_amount].present? && params[:max_amount].present?
      min_amount = params[:min_amount].to_f
      max_amount = params[:max_amount].to_f
      
      if min_amount > max_amount
        errors << "Minimum amount cannot be greater than maximum amount"
      end
    end
  end
end
