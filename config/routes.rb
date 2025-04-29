Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      # Auth routes
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      
      # Protected routes
      resources :users, only: [:index, :show, :update]
      get 'profile', to: 'users#profile'
      
      # Asset routes
      resources :assets do
        collection do
          post 'bulk_import'
        end
      end
      
      # Purchase routes
      resources :purchases, only: [:index, :show, :create] do
        member do
          get 'download'
        end
      end
      
      # Admin routes
      namespace :admin do
        get 'creator_earnings'
        get 'platform_statistics'
      end
    end
  end
end
