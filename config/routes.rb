Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               omniauth_callbacks: 'sessions'
             }

  devise_scope :user do
    get 'sign_out', to: 'sessions#destroy'
  end

  root 'application#index'
  get 'about', to: 'application#about'
  get 'api_documentation', to: 'application#api'

  resources :submissions
  resources :plant_lines, only: [:index]
  resources :plant_varieties, only: [:index]
  resources :data_tables, only: [:index, :show]

  get 'search', to: 'searches#counts'
  get 'browse_data', to: 'data_tables#index', defaults: { model: 'plant_populations' }

  resource :api_keys, only: [:show] do
    member do
      put :recreate
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :resources, except: [:new]

      Api.readable_models.map { |klass| klass.name.underscore.pluralize }.each do |model_name|
        get "#{model_name}", to: 'resources#index'
        get "#{model_name}/:id", to: 'resources#show'
      end

      Api.writable_models.map { |klass| klass.name.underscore.pluralize }.each do |model_name|
        post "#{model_name}", to: 'resources#create'
        put "#{model_name}/:id", to: 'resources#update'
        patch "#{model_name}/:id", to: 'resources#update'
        delete "#{model_name}/:id", to: 'resources#destroy'
      end
    end
  end
end
