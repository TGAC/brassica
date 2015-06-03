class Api::BaseController < ActionController::Metal
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

  include Rails.application.routes.url_helpers
end
