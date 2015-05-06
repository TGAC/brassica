class Api::CollectionDecorator < Draper::CollectionDecorator
  def decorator_class
    Api::Decorator
  end

  def meta
    {
      page: object.current_page,
      per_page: object.limit_value,
      total_count: object.total_count
    }
  end
end
