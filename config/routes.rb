Rails.application.routes.draw do
  root "pages#dashboard"
  
  resources :accounts, only: [:new, :create]
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  resources :users, only: [:new, :create, :edit, :update, :destroy]

  resources :meal_plans, only: [:new, :create, :show] do
    member do
      post :advance_day
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
