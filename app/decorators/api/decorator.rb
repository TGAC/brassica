class Api::Decorator < Draper::Decorator
  delegate_all

  def attribute_names
    object.class.table_columns + object.class.ref_columns
  end

  def as_json(*)
    object.as_json(only: attribute_names)
  end
end
