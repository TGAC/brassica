class ApiKeysController < ApplicationController

  before_filter :authenticate_user!

  def show
    render text: current_user.api_key.try(:token)
  end

end
