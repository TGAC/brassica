# FIXME extend ActionController::Metal instead as some mixins are not needed
class Api::V1::ResourcesController < ApplicationController
  include Pagination

  before_filter :authenticate_api_key!
  before_filter :require_allowed_model
  before_filter :require_proper_input, except: [:index, :show]

  def index
    filter_params = params[model_name.singularize].presence

    resources = filter_params ? model_klass.filter(filter_params) : model_klass.all
    resources = paginate_collection(resources)
    resources = decorate_collection(resources)

    render json: { model_name => resources, :meta => resources.meta }
  end

  def show
    resource = model_klass.find(params[:id])
    render json: decorate(resource)
  end

  def create
    resource = model_klass.new(create_params)

    if resource.save
      render json: { model_name.singularize => decorate(resource) }, status: :created
    else
      render json: {}, status: 422
    end
  end

  private

  def authenticate_api_key!
    token = ApiKey.normalize_token(params[:api_key])
    unless token.present? && ApiKey.exists?(token: params[:api_key])
      render text: "Not Found", status: 404
    end
  end

  def require_allowed_model
    if request.request_method_symbol == :get && !Brassica::Api.readable_model?(model_name)
      raise ActionController::RoutingError.new('Not Found')
    end
    if request.request_method_symbol != :get && !Brassica::Api.writable_model?(model_name)
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def require_proper_input
    model_attrs = model_klass.attribute_names
    misnamed_attrs = (params[model_name.singularize].try(:keys) || []) - model_attrs

    if misnamed_attrs.present?
      render json: {}, status: 422
    end
  end

  def model_name
    @model_name ||= request.path.match(/\A\/api\/v1\/(([\w_]+)\/?)/)[2]
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
    # FIXME extract ParamValidator or sth
    blacklisted_attrs = %w(id)
    permitted_attrs =  model_klass.attribute_names - blacklisted_attrs

    params.require(model_name.singularize).permit(permitted_attrs)
  end

end
