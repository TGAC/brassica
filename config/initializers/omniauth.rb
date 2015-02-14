Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :orcid,
           Rails.application.secrets.orcid_key,
           Rails.application.secrets.orcid_secret,
           Rails.application.config_for(:orcid)
end
