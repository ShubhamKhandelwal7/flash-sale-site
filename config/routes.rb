Rails.application.routes.draw do
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout'  => :destroy
  end
  <ge></ge>t 'dummy_homepage', action: :dummy_homepage, controller: 'dummy'
  get "verify/:token", action: :verify, controller: :users, as: 'verify'

  resources :users, only: [:new, :create]

  resources :password_resets, only: [:new, :create, :edit, :update], param: :token
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
