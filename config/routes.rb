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
      get "jobs/:id/on_progress" => "jobs#on_progress"
      get "jobs/:id/complete" => "jobs#complete"
      get "jobs/:id/incomplete" => "jobs#incomplete"

      resources :skills
      resources :job_categories
      resources :school_partners
      resources :user_messages

      resources :job_requests do
        resources :reviews, on: :member
      end
      get "job_requests/:id/accept" => "job_requests#accept"
      get "job_requests/:id/reject" => "job_requests#reject"
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

  root  'home#home'

  resources :jobs
  resources :job_categories
  resources :job_requests
  resources :skills
  resources :pictures
end
