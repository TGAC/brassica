class Api::CreateParams

  attr_accessor :model_name, :model_klass, :request_params

  def initialize(model_name, request_params)
    self.model_name = model_name
    self.model_klass = model_name.classify.constantize
    self.request_params = request_params
  end

  def permitted
    permitted_attrs = model_attrs - blacklisted_attrs
    permitted_attrs.append Hash[habtm_attrs.zip([[]] * habtm_attrs.size)]

    request_params.require(model_name).permit(permitted_attrs)
  end

  def misnamed_attrs
    (request_params[model_name].try(:keys) || []) - (model_attrs | habtm_attrs)
  end

  private

  def model_attrs
    model_klass.attribute_names
  end

  def habtm_attrs
    finder = Api::AssociationFinder.new(model_klass)
    finder.has_and_belongs_to_many_associations.map(&:param)
  end

  def blacklisted_attrs
    %w(id user_id created_at updated_at date_entered entered_by_whom)
  end

end
