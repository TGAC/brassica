class Api::Index

  attr_accessor :model

  def initialize(model)
    self.model = model
  end

  def where(filter_params)
    if filter_params.present? && filterable?
      model.klass.filter(filter_params)
    elsif filter_params.present? && !filterable?
      raise "#{model.klass} does not support #{filter_params.keys}"
    else
      model.klass.all
    end
  end

  private

  def filterable?
    model.klass.ancestors.include?(Filterable)
  end
end
