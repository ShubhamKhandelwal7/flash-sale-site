Rails.application.routes.draw do
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout'  => :destroy
  end

  resources :users do
    get "verify", on: :member
  end
  resources :password_resets
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
