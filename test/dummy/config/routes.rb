Rails.application.routes.draw do
  # Products CRUD - Example for BetterPage testing
  resources :products

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "products#index"
end
