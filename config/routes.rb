Rails.application.routes.draw do
  get  "register", to: "users#new", as: :register
  post "register", to: "users#create"

  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  resources :games, only: [:create, :show] do
    resources :moves, only: [:create]
  end

  root "home#index"
end