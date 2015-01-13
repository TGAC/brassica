Rails.application.routes.draw do
  devise_for :users

  root 'application#index'
end
