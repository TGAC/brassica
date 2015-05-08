class ApiKeysController < ApplicationController

  before_filter :authenticate_user!

  def show
    @api_key = current_user.api_key

    respond_to do |format|
      format.json { render json: { api_key: @api_key.try(:token) } }
      format.html
    end
  end

  def recreate
    current_user.api_key.try(:destroy)
    current_user.create_api_key!

    redirect_to api_keys_url, notice: 'API Key renewed'
  end

end
