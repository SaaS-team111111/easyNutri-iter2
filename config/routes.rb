Rails.application.routes.draw do
  # Landing dashboard
  root "pages#dashboard"

  # User management
  resources :users, only: [:new, :create]

  # MealPlan management (independent of users in routes)
  resources :meal_plans, only: [:new, :create, :show]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
