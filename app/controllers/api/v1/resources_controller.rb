# FIXME extend ActionController::Metal instead as some mixins are not needed
class Api::V1::ResourcesController < ApplicationController
  include Pagination

  before_filter :authenticate_api_key!
  before_filter :require_allowed_model
  before_filter :require_strictly_correct_params, only: :create

  def index
    filter_params = params[model_name].presence

    resources = filter_params ? model_klass.filter(filter_params) : model_klass.all
    resources = paginate_collection(resources)
    resources = decorate_collection(resources)

    render json: { model_name.pluralize => resources, :meta => resources.meta }
  end

  def show
    resource = model_klass.find(params[:id])
    render json: { model_name => decorate(resource) }
  end

  def create
    resource = model_klass.new(create_params.merge(:user_id => api_key.user_id))

    if resource.save
      render json: { model_name => decorate(resource) }, status: :created
    else
      errors = []

      resource.errors.messages.each do |attr, messages|
        messages.each do |msg|
          errors << { attribute: attr, message: msg.capitalize }
        end
      end

      render json: { errors: errors }, status: 422
    end
  end

  private

  def authenticate_api_key!
    unless api_key.present?
      render text: "Not Found", status: 404
    end
  end

  def api_key
    return @api_key if defined?(@api_key)

    token = params[:api_key] || request.headers["X-BIP-Api-Key"]
    token = ApiKey.normalize_token(token)

    @api_key = token && ApiKey.find_by(token: token)
  end

  def require_allowed_model
    if request.request_method_symbol == :get && !Api.readable_model?(model_name)
      raise ActionController::RoutingError.new('Not Found')
    end
    if request.request_method_symbol != :get && !Api.writable_model?(model_name)
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def require_strictly_correct_params
    model_attrs = model_klass.attribute_names
    misnamed_attrs = (params[model_name].try(:keys) || []) - model_attrs

    if misnamed_attrs.present?
      errors = []

      misnamed_attrs.each do |attr|
        errors << { attribute: attr, message: "Unrecognized attribute name" }
      end

      render json: { errors: errors }, status: 422
    end
    true
  end

  def model_name
    @model_name ||= request.path.match(/\A\/api\/v1\/(([\w_]+)\/?)/)[2].singularize
  end

  def model_klass
    @model_klass ||= model_name.classify.constantize
  end

  def decorate_collection(resources)
    Api::CollectionDecorator.decorate(resources || [])
  end

  def decorate(resource)
    Api::Decorator.decorate(resource)
  end

  def create_params
    blacklisted_attrs = %w(id user_id)
    model_attrs = model_klass.attribute_names
    permitted_attrs =  model_attrs - blacklisted_attrs

    params.require(model_name).permit(permitted_attrs)
  end

end
