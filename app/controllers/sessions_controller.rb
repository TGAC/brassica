class SessionsController < Devise::OmniauthCallbacksController
  def orcid
    extra_info = OrcidClient.get_user_data(auth_hash['uid'])
    if extra_info && extra_info[:status] == :ok
      auth_hash[:full_name] = extra_info[:full_name]
    else
      flash[:alert] = extra_info[:message] if extra_info
    end
    @user = User.find_or_create_from_auth_hash(auth_hash)
    if @user.persisted?
      sign_in_and_redirect(@user, event: :authentication)
      set_flash_message(:notice, :success, kind: 'ORCiD')
    end
  end

  def after_omniauth_failure_path_for(scope)
    root_path
  end

  def destroy
    signed_out = sign_out
    set_flash_message(:notice, :signed_out) if signed_out
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
