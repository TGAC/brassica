class Api::Decorator < Draper::Decorator
  delegate_all

  def as_json(*)
    object.as_json
  end
end
