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
  get 'make_me_an_error', to: 'application#make_me_an_error'

  resources :submissions do
    resources :uploads, controller: 'submissions/uploads', only: [:create, :destroy]
  end
  resources :plant_lines, only: [:index]
  resources :plant_varieties, only: [:index]
  resources :plant_populations, only: [:index]
  resources :trait_descriptors, only: [:index]
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
      get_constraints = {
        plural_model_name: /#{Api.readable_models.map { |klass| klass.name.underscore.pluralize }.join("|")}/
      }

      post_constraints = {
        plural_model_name: /#{Api.writable_models.map { |klass| klass.name.underscore.pluralize }.join("|")}/
      }

      get ":plural_model_name", to: 'resources#index', constraints: get_constraints
      get ":plural_model_name/:id", to: 'resources#show', constraints: get_constraints
      post ":plural_model_name", to: 'resources#create', constraints: post_constraints
      delete ":plural_model_name/:id", to: 'resources#destroy', constraints: post_constraints
    end
  end
end
