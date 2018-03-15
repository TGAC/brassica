class Api::CreateParams

  attr_accessor :model, :request_params

  def initialize(model, request_params)
    self.model = model
    self.request_params = request_params
  end

  def permitted_params
    request_params.require(model.name).permit(permissions)
  rescue NoMethodError
    fail Api::InvalidParams, "Request params could not be parsed"
  end

  def permissions
    perms = scalar_attrs - blacklisted_attrs
    nonscalar_attrs = habtm_attrs + array_attrs
    if nonscalar_attrs.present?
      # Append a hash like { attr1: [], attr2: [], ... }
      perms.append(Hash[nonscalar_attrs.zip([[]] * nonscalar_attrs.size)])
    end
    perms
  end

  def misnamed_attrs
    (request_params[model.name].try(:keys) || []) - (nonrelational_attrs | habtm_attrs)
  end

  private

  def nonrelational_attrs
    model.klass.attribute_names
  end

  def scalar_attrs
    model.klass.attribute_names.reject do |attribute_name|
      attribute_name.ends_with?("_count") || model.klass.columns_hash[attribute_name].array
    end
  end

  def array_attrs
    model.klass.attribute_names.select do |attribute_name|
      model.klass.columns_hash[attribute_name].array
    end
  end

  def habtm_attrs
    model.has_and_belongs_to_many_associations.map(&:param)
  end

  def blacklisted_attrs
    %w(id user_id created_at updated_at date_entered entered_by_whom published_on)
  end

end
