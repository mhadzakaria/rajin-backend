Rails.application.routes.draw do
  devise_for :mentors
  # Start API routes
  namespace :api do
    namespace :v1 do
      # devise_for :users, :controllers => {
      #   sessions: "api/v1/users/sessions",
      #   registrations: "api/v1/users/registrations",
      #   passwords: "api/v1/users/passwords",
      #   invitations: "api/v1/users/invitations",
      #   omniauth_callbacks: 'api/v1/users/omniauth_callbacks'
      # }

      # devise_scope :user do
      #   get "users/profile", to: "users/sessions#show", as: :user_profile
      # end

      devise_for :mentors, :controllers => {
        sessions: "api/v1/mentors/sessions",
        registrations: "api/v1/mentors/registrations",
        passwords: "api/v1/mentors/passwords"
      }

      devise_scope :mentor do
        get "mentors/profile", to: "mentors/sessions#show", as: :mentor_profile
      end

      resources :jobs do
        collection do
          get "filter"
        end

        member do
          get "on_progress" => "jobs#on_progress"
          get "complete" => "jobs#complete"
          get "incomplete" => "jobs#incomplete"
        end
      end

      resources :skills
      resources :job_categories
      resources :school_partners
      resources :coin_packages, only: [:index, :show]
      resources :notifications, only: [:show, :destroy] do
        collection do
          get :user_notifications
        end
      end

      resources :job_requests do
        resources :reviews, on: :member
        put "reject" => "job_requests#reject", on: :member
        put "accept" => "job_requests#accept", on: :member
      end

      resources :orders, only: [:index, :show, :create] do
        collection do
          post "ipay88"         => "orders#ipay88"
          post "ipay88_backend" => "orders#ipay88_backend"
          # get "ipay88_test"    => "orders#ipay88_test"
        end
      end
    end
  end
  # End API routes

    # registrations: "users/registrations",
  devise_for :users, :controllers => {
    sessions: "users/sessions",
    passwords: "users/passwords",
    invitations: "users/invitations"
  }

  devise_scope :user do
    get "users/profile", to: "users/sessions#show", as: :user_profile
  end


  namespace :admin do
    resources :coin_packages
    resources :companies
    resources :jobs
    resources :job_categories
    resources :job_requests
    resources :mentors, only: %w[index show]
    resources :orders, only: %w[index show]
    resources :pictures
    resources :skills
    resources :school_partners
    resources :roles
    resources :users do
      member do
        get 'top_up'
        get 'top_up_process'
        get 'resend_invitation'
      end
    end

    root to: 'home#home', as: :root
  end

  root  'admin/home#home'

  # Handing error no route match
  match "*path", to: "application#error_404", via: :all
end
