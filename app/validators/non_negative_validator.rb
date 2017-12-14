class NonNegativeValidator < ActiveModel::Validations::NumericalityValidator
  def initialize(options = {})
    options.merge!(greater_than_or_equal_to: 0)

    super(options)
  end
end
