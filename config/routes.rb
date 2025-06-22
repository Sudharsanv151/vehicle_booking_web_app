Rails.application.routes.draw do

  root "users#select_role"

  get "select_role", to: "users#select_role"
  get "home", to: "users#home"
  resources :users, only: [:new, :create]

  resources :vehicles do
    get "ratings", to: "vehicles#ratings"
    get "bookings", to: "vehicles#ride_history"
  end

  resources :bookings, only: [:new, :create, :index, :destroy] do
    member do
      patch :accept
      patch :finish
      patch :reject
    end
  end

  resources :payments, only: [:new, :create]

  resources :ratings, only: [:new, :create]

  #CUSTOM ROUTES
  get "customer/ride_history", to: "bookings#customer_history", as: :customer_ride_history
  get "driver/ride_history", to: "bookings#driver_history", as: :driver_ride_history
  get "driver/ongoing", to: "bookings#driver_ongoing", as: :driver_ongoing
  get "driver/vehicles", to: "vehicles#driver_index", as: :driver_vehicles
  get "booking_requests", to: "bookings#requests", as: :booking_requests

end
