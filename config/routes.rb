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

  resources :submissions
  resources :plant_lines, only: [:index]
  resources :data_tables, only: [:index, :show]

  get 'browse_data', to: 'data_tables#index', defaults: { model: 'plant_populations' }
end
