class Brapi::BaseController < ActionController::Metal
  include AbstractController::Rendering
  include ActionController::Helpers
  include ActionController::Redirecting
  include ActionController::Rendering
  include ActionController::Renderers
  include ActionController::Renderers::All
  include ActionController::ConditionalGet
  include ActionController::EtagWithTemplateDigest
  include ActionController::MimeResponds
  include ActionController::Caching
  include ActionController::ForceSSL
  include AbstractController::Callbacks
  include ActionController::Instrumentation
  include ActionController::ParamsWrapper
  include ActionController::StrongParameters
  include ActionController::Rescue

  include Rails.application.routes.url_helpers
  
  
  rescue_from 'Brapi::QueryError' do |ex|
    Rails.logger.warn { "Encountered an error executing a BrAPI-related query: #{ex.message} #{ex.backtrace.join("\n")}" }
    ExceptionNotifier.notify_exception(ex, env: request.env, data: { sql: ex.sql, cause: ex.cause.message })
    render json: { reason: 'Internal error', message: 'There was some error managing Brapi query' }, status: :internal_server_error
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: { attribute: exception.param, message: exception.message } }, status: 422
  end 
  
end
