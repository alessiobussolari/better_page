Rails.application.routes.draw do
  # Lookbook for component previews
  if Rails.env.development?
    mount Lookbook::Engine, at: "/lookbook"
  end

  # Products CRUD - Example for BetterPage testing
  resources :products

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "products#index"
end
