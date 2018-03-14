class Api::IndexParams

  attr_accessor :model, :request_params, :user

  def initialize(model, request_params, user)
    self.model = model
    self.request_params = request_params
    self.user = user
  end

  def params
    # NOTE: Filterable module takes care of param-safety
    (request_params.to_unsafe_h[model.name] || {}).tap do |params|
      if request_params[:only_mine]
        params[:query] = (params[:query]&.to_h || {}).merge(user_id: user.id)
      end
    end
  end
end
