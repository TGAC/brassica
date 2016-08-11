class Api::Index

  attr_accessor :model, :user

  def initialize(model, user)
    self.model = model
    self.user = user
  end

  def where(filter_params)
    resources = filter_resources(filter_params)
    resources = resources.visible(user.id) if resources.respond_to? :visible
    load_associations(resources)
    resources
  end

  private

  def filter_resources(filter_params)
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

  def filterable?
    model.klass.ancestors.include?(Filterable)
  end
end
