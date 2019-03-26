Rails.application.routes.draw do
  devise_for :mentors
  # Start API routes
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      devise_for :users, :controllers => {
        sessions: "api/v1/users/sessions",
        registrations: "api/v1/users/registrations",
        passwords: "api/v1/users/passwords"
      }

      devise_scope :user do
        get "users/profile", to: "users/sessions#show", as: :user_profile
      end

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

      resources :job_requests do
        resources :reviews, on: :member
        put "reject" => "job_requests#reject", on: :member
        put "accept" => "job_requests#accept", on: :member
      end
    end
  end
  # End API routes

  devise_for :users, :controllers => {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  devise_scope :user do
    get "users/profile", to: "users/sessions#show", as: :user_profile
  end


  namespace :admin do
    resources :jobs
    resources :job_categories
    resources :job_requests
    resources :skills
    resources :pictures
    resources :companies
    resources :school_partners
    resources :users, only: [:index, :show]
    resources :mentors, only: [:index, :show]

    root to: 'home#home', as: :root
  end

  root  'admin/home#home'
end
