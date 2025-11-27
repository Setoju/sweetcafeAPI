Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/signup', to: 'auth#signup'
      post 'auth/login', to: 'auth#login'
      get 'auth/me', to: 'auth#me'
      delete 'auth/signout', to: 'auth#signout'

      # Categories routes
      resources :categories, only: [:index, :show, :create, :update, :destroy]

      # Menu Items routes
      resources :menu_items, only: [:index, :show, :create, :update, :destroy]

      # Orders routes
      resources :orders, only: [:index, :show, :create, :update] do
        member do
          post :cancel
        end
      end

      # Users routes
      resources :users, only: [:index, :show, :update, :destroy] do
        member do
          get :orders
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
