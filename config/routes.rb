Rails.application.routes.draw do
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout'  => :destroy
  end

  #FIXME_AB: lets use :only or :except to have routes that actually needed
  resources :users do
    get "verify", on: :member
  end

  #FIXME_AB: use :only to make routes
  resources :password_resets
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
