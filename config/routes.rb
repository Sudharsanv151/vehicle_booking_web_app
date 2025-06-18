Rails.application.routes.draw do
  root "users#select_role"
  get "select_role", to: "users#select_role"
  get "home", to: "users#home"

  resources :users, only: [:new, :create]

  resources :vehicles, only: [:new, :create, :edit, :update, :destroy]

  resources :bookings, only: [:new, :create] do
    member do
      patch :accept   
      patch :finish  
      delete :destroy
    end
  end

  resources :payments, only: [:new, :create]
  resources :ratings, only: [:new, :create]

  get "up" => "rails/health#show", as: :rails_health_check

end
