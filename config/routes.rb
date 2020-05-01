Rails.application.routes.draw do
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout'  => :destroy
  end
  
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  root 'home#index', as: 'home'
  get "verify/:token", action: :verify, controller: :users, as: 'verify'

  resources :users, only: [:new, :create]

  resources :password_resets, only: [:new, :create, :edit, :update], param: :token

  resources :line_items, only: [:destroy]
  resources :orders do
    get "add_to_cart", on: :member
  end

  namespace :admin do
    get "/", to: "home#index", as: "home"
    resources :deals do
      get "check_publishability", on: :member, action: "check_publishability"
      delete "delete_image_attachment", on: :member
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
