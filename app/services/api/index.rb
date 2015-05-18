class Api::Index

  attr_accessor :model_klass

  def initialize(model_klass)
    self.model_klass = model_klass
  end

  def where(filter_params)
    if filter_params.present? && filterable?
      model_klass.filter(filter_params)
    elsif filter_params.present? && !filterable?
      raise "#{model_klass} does not support #{filter_params.keys}"
    else
      model_klass.all
    end
  end

  private

  def filterable?
    model_klass.ancestors.include?(Filterable)
  end
end
