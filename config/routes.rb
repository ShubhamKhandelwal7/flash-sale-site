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
  resources :orders, only: :index do
    collection do
      get "buy_now"
      get "checkout"
    end
    member do
      get "add_to_cart"
      delete "rem_from_cart"
      get "select_address"
    end
  end

  namespace :admin do
    get "/", to: "deals#index"
    resources :deals do
      member do
        get "check_publishability", action: "check_publishability"
        get "delete_image_attachment"
        get "publish", action: "publish"
        get "unpublish", action: "unpublish"
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
