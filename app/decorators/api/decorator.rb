class Api::Decorator < Draper::Decorator
  delegate_all

  # FIXME check if these are ok
  def api_attribute_names
    object.class.table_columns + object.class.ref_columns
  end

  def as_json(*)
    object.as_json(only: api_attribute_names)
  end
end
