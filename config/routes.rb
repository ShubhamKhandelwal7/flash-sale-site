Rails.application.routes.draw do
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout'  => :destroy
  end

  # // for time being lets open letter opener for all envs
  mount LetterOpenerWeb::Engine, at: "/letter_opener" #if Rails.env.development?

  root 'home#index', as: 'home'
  get "verify/:token", action: :verify, controller: :users, as: 'verify'
  get "homedeals", to: "home#deals"

  resources :users, only: [:new, :create]

  resources :password_resets, only: [:new, :create, :edit, :update], param: :token

  resources :addresses, only: [:create, :new]
  resources :orders do
    get "add_to_cart", on: :member
    delete "rem_from_cart", on: :member
    get "buy_now", on: :collection
    get "checkout", on: :collection
    get "select_address", on: :member
  end

  namespace :admin do
    get "/", to: "home#index", as: "home"
    resources :deals do
      get "check_publishability", on: :member, action: "check_publishability"
      get "delete_image_attachment", on: :member
      get "sort", on: :collection, action: "sort"
      get "publish", on: :member, action: "publish"
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
