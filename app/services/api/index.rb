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

  def load_associations(query)
    if model.klass.respond_to?(:json_options)
      included_relations = model.klass.json_options[:include]
      query = query.includes(included_relations).references(included_relations) if included_relations
    end
    query
  end

  private

  def filterable?
    model.klass.ancestors.include?(Filterable)
  end
end
