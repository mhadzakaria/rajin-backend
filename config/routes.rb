Rails.application.routes.draw do
  devise_for :menthors
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

      resources :jobs
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
