class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index; end

  private

  # Required by devise/omniauth when not using :database_authenticatable
  # NOTE: remove if :database_authenticatable is switched ON
  def new_session_path(scope)
    root_path
  end
end
