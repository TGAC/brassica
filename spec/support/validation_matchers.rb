module ValidationMatchers
  def validate_as_non_negative(attr)
    validate_numericality_of(attr).is_greater_than_or_equal_to(0)
  end

  def validate_as_temperature(attr)
    validate_numericality_of(attr).is_greater_than_or_equal_to(-273.15)
  end

  def validate_as_ratio(attr)
    validate_numericality_of(attr).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1)
  end
end
