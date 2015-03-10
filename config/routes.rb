Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               omniauth_callbacks: 'sessions'
             }

  devise_scope :user do
    get 'sign_out', to: 'sessions#destroy'
  end

  root 'application#index'

  resources :submissions
  resources :plant_populations, only: [:index]
  resources :plant_lines, only: [:index]
end
