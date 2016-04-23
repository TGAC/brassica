class Api::CreateParams

  attr_accessor :model, :request_params

  def initialize(model, request_params)
    self.model = model
    self.request_params = request_params
  end

  def permitted_params
    request_params.require(model.name).permit(permissions)
  end

  def permissions
    perms = scalar_attrs - blacklisted_attrs
    if habtm_attrs.present?
      # Append a hash like { attr1: [], attr2: [], ... }
      perms.append(Hash[habtm_attrs.zip([[]] * habtm_attrs.size)])
    end
    perms
  end

  def misnamed_attrs
    (request_params[model.name].try(:keys) || []) - (scalar_attrs | habtm_attrs)
  end

  private

  def scalar_attrs
    model.klass.attribute_names
  end

  def habtm_attrs
    model.has_and_belongs_to_many_associations.map(&:param)
  end

  def blacklisted_attrs
    %w(id user_id created_at updated_at date_entered entered_by_whom published_on)
  end

end
