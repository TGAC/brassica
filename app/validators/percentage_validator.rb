class PercentageValidator < ActiveModel::Validations::NumericalityValidator
  def initialize(options = {})
    options.merge!(greater_than_or_equal_to: 0, less_than_or_equal_to: 100)

    super(options)
  end
end
