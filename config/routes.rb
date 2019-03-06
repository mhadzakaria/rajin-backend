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

      resources :jobs
      resources :skills
      resources :job_categories
      resources :school_partners

      resources :job_requests do
        resources :reviews, on: :member
      end
    end
  end
  # End API routes

  devise_for :users, :controllers => {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  root  'home#home'
end
