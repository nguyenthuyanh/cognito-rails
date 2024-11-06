Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root "application#index"
  get "/logout", to: "pognito#logout"
  get "/login", to: "pognito#login"

  namespace :dashboard do
    root "application#index"

    get "/profile", to: "user#index"

    resources :projects, only: [:index, :show, :update]
  end
end
