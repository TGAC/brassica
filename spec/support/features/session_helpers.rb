module Features
  module SessionHelpers
    def sign_up_with(attrs)
      visit new_user_registration_path
      fill_in 'Name', with: attrs[:name]
      fill_in 'E-mail', with: attrs[:email]
      fill_in 'Password', with: attrs[:password]
      fill_in 'Password confirmation', with: attrs[:password_confirmation]
      fill_in 'Phone', with: attrs[:name]
      fill_in 'Address', with: attrs[:address]
      fill_in 'Affiliation', with: attrs[:affiliation]
      click_button 'Sign up'
    end

    def signin(email, password)
      visit new_user_session_path
      fill_in 'E-mail', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def current_params
      Rack::Utils.parse_nested_query(URI.parse(current_url).query).deep_symbolize_keys
    end
  end
end
