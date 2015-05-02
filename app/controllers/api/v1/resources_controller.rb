# FIXME extend ActionController::Metal instead as some mixins are not needed
class Api::V1::ResourcesController < ApplicationController

  before_filter :authenticate_api_key!, except: :new
  before_filter :require_allowed_model

  # FIXME find a way to document api calls

  def index
    # FIXME support pagination
    filter_params = params[model_name.singularize].presence
    resources = filter_params ? model_klass.filter(filter_params) : model_klass.all
    render json: { model_name => Api::Decorator.decorate_collection(resources || []) }
  end

  def show
    object = model_param.singularize.camelize.constantize.find(params[:id])
  end

  private

  def authenticate_api_key!
    token = ApiKey.normalize_token(params[:api_key])
    unless token.present? && ApiKey.exists?(token: params[:api_key])
      render text: "Not Found", status: 404
    end
  end

  def require_allowed_model
    unless allowed_models.include?(model_name)
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def model_name
    @model_name ||= request.path.match(/\A\/api\/v1\/(([\w_]+)\/?)/)[1]
  end

  def model_klass
    @model_klass ||= model_name.singularize.camelize.constantize
  end

  def allowed_models
    %w(plant_lines)
  end
end
