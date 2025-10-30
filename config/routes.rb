Rails.application.routes.draw do
  root "pages#dashboard"
  resources :users, only: [:new, :create]

  resources :meal_plans, only: [:new, :create, :show]
  get "up" => "rails/health#show", as: :rails_health_check
end
