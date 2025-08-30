class InvoiceValidationService
  attr_reader :validator

  def initialize(validator: InvoiceSearchValidator.new)
    @validator = validator
  end

  def validate_search_params(params)
    validator.validate(params)
  end
end
