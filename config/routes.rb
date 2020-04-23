Rails.application.routes.draw do
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout'  => :destroy
  end
  # get 'home', action: :dummy_homepage, controller: 'dummy'
  root 'home#index', as: 'home'
  get "verify/:token", action: :verify, controller: :users, as: 'verify'

  resources :users, only: [:new, :create]

  resources :password_resets, only: [:new, :create, :edit, :update], param: :token

  namespace :admin do 
    resources :deals do
      get "check_publishability", on: :member, action: "check_publishability"
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
