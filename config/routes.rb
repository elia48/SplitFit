Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: "users/registrations" }
  
  resources :users, only: [:show, :edit, :update]

  root to: "trainings#index"
  get "search", to: "pages#search", as: :search
  get "coach-welcome", to: "pages#coach_welcome", as: :coach_welcome
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :trainings, except: [:destroy] do
    member do
      patch :cancel
      patch :publish
      patch :close
    end
    
    resources :bookings, only: [:create]
    resources :reviews, only: [:create]
    resources :messages, only: [:create, :index]
  end
  resources :bookings, only: [:show, :destroy, :index] do
    resources :payments, only: [:new]
  end
  resources :reviews, only: [:destroy, :index]
  resources :messages, only: [:index]

  resources :private_chats, only: [:show, :create] do
    resources :private_messages, only: [:create]
  end

  mount StripeEvent::Engine, at: "/stripe-webhooks"

  get "stripe/onboard", to: "stripe_connect#onboard", as: :stripe_connect_onboard
  get "stripe/return",  to: "stripe_connect#return",  as: :stripe_connect_return
  get "stripe/refresh", to: "stripe_connect#refresh", as: :stripe_connect_refresh
  
  namespace :retell do
    post "web_call"
    post "call_data"
  end
end
