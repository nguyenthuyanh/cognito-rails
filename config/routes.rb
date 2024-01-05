Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root "index#index"
  get "/logout", to: "pognito#logout"
  get "/login", to: "pognito#login"
  get "/user", to: "index#user"
end


