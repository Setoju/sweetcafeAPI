Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      get "auth/me", to: "auth#me"
      patch "auth/me", to: "auth#update_profile"
      delete "auth/signout", to: "auth#signout"

      # OAuth routes
      post "auth/google", to: "oauth#google"
      get "auth/google/callback", to: "oauth#google_callback"
      post "auth/google/callback", to: "oauth#google_callback"
      post "auth/google/exchange", to: "oauth#exchange_code"

      # Categories routes
      resources :categories, only: [ :index, :show, :create, :update, :destroy ]

      # Menu Items routes
      resources :menu_items, only: [ :index, :show, :create, :update, :destroy ]

      # Orders routes
      resources :orders, only: [ :index, :show, :create, :update ] do
        member do
          post :cancel
        end
      end

      # Users routes
      resources :users, only: [ :index, :show, :update, :destroy ] do
        member do
          get :orders
        end
      end

      # Cart routes
      get "cart", to: "cart_items#index"
      post "cart", to: "cart_items#create"
      delete "cart/clear", to: "cart_items#clear"
      patch "cart/:id", to: "cart_items#update"
      put "cart/:id", to: "cart_items#update"
      delete "cart/:id", to: "cart_items#destroy"

      # Deliveries routes
      resources :deliveries, only: [ :index, :show, :create, :update, :destroy ]
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
