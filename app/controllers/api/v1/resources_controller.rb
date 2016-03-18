class Api::V1::ResourcesController < Api::BaseController
  include Pagination

  before_filter :authenticate_api_key!
  before_filter :require_allowed_model
  before_filter :require_strictly_correct_params, only: :create

  rescue_from 'ActiveRecord::InvalidForeignKey' do |exception|
    message = exception.message.split("\n").try(:second)
    attribute = message ? message[14..-1].split(')')[0] : ''
    render json: { errors: { attribute: attribute, message: message } }, status: 422
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: { attribute: exception.param, message: exception.message } }, status: 422
  end

  def index
    filter_params = params[model.name].presence

    resources = Api::Index.new(model).where(filter_params).order(:id)
    resources = paginate_collection(resources)
    resources = decorate_collection(resources)

    render json: { model.name.pluralize => resources, :meta => resources.meta }
  end

  def show
    resource = model.klass.find(params[:id])
    render json: { model.name => decorate(resource) }
  end

  def create
    resource = model.klass.new(
      create_params.merge(
        :user_id => api_key.user_id,
        :date_entered => Date.today,
        :entered_by_whom => api_key.user.full_name,
        :published => true,
        :published_on => Date.today
      )
    )

    if resource.save
      render json: { model.name => decorate(resource) }, status: :created
    else
      errors = resource.errors.messages.map do |attr, messages|
        messages.map do |msg|
          { attribute: attr, message: msg.capitalize }
        end
      end.flatten

      render json: { errors: errors }, status: 422
    end
  end

  def destroy
    resource = model.klass.find_by(id: params[:id])
    if resource.nil?
      render json: { reason: 'Resource not found' }, status: :not_found
    elsif resource.user != @api_key.user
      render json: { reason: 'API key owner and resource owner mismatch' }, status: :unauthorized
    elsif resource.published?
      render json: { reason: 'This resource is already published and irrevocable' }, status: :forbidden
    else
      resource.destroy
      head :no_content
    end
  end

  private

  def authenticate_api_key!
    unless api_key_token.present?
      render json: '{"reason": "BIP API requires API key authentication"}', status: 401
      return
    end
    unless api_key.present?
      if api_key_token == I18n.t('api.general.demo_key')
        render json: '{"reason": "Please use your own, personal API key"}', status: 401
      else
        render json: '{"reason": "Invalid API key"}', status: 401
      end
    end
  end

  def api_key_token
    return @api_key_token if defined?(@api_key_token)
    token = params[:api_key] || request.headers["X-BIP-Api-Key"]
    @api_key_token = ApiKey.normalize_token(token)
  end

  def api_key
    return @api_key if defined?(@api_key)
    @api_key = api_key_token && ApiKey.find_by(token: api_key_token)
  end

  def require_allowed_model
    if request.request_method_symbol == :get && !Api.readable_model?(model.name)
      raise ActionController::RoutingError.new('Not Found')
    end
    if request.request_method_symbol != :get && !Api.writable_model?(model.name)
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def require_strictly_correct_params
    misnamed_attrs = Api::CreateParams.new(model, params).misnamed_attrs
    if misnamed_attrs.present?
      errors = misnamed_attrs.map do |attr|
        { attribute: attr, message: "Unrecognized attribute name" }
      end

      render json: { errors: errors }, status: 422
    end
    true
  end

  def model
    @model ||= Api::Model.new(params.fetch(:plural_model_name).singularize)
  end

  def decorate_collection(resources)
    Api::CollectionDecorator.decorate(resources || [])
  end

  def decorate(resource)
    Api::Decorator.decorate(resource)
  end

  def create_params
    Api::CreateParams.new(model, params).permitted_params
  end

end
