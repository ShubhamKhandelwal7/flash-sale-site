Rails.application.routes.draw do
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout'  => :destroy
  end
  get 'dummy_homepage', action: :dummy_homepage, controller: 'dummy'
  get "verify/:token", action: :verify, controller: :users, as: 'verify'

  #FIXME_AB: lets use :only or :except to have routes that actually needed
  resources :users, only: [:new, :create]

  #FIXME_AB: use :only to make routes
  resources :password_resets, only: [:new, :create, :edit, :update], param: :token
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
