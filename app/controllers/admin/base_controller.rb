class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    return if current_user && current_user.admin?
    redirect_to root_path
  end
end
