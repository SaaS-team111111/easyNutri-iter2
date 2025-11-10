Rails.application.routes.draw do
  root "pages#dashboard"
  resources :users, only: [:new, :create]

  resources :meal_plans, only: [:new, :create, :show] do
    member do
      post :advance_day
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
