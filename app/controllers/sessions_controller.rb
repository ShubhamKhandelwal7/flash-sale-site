class SessionsController < ApplicationController

  include UserPresence
  skip_before_action :authorize, except: :destroy
  before_action :ensure_not_logged_in, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.signed[:user_id] = { value: user.id, expires: ENV["REMEMBER_ME_COOKIE_EXPIRY_DAYS"].to_i.days.from_now }
      else
        session[:user_id] = user.id
      end
      redirect_to home_path, notice: t(".flash.success")
    else
      redirect_to login_path, alert: t(".flash.failure")
    end
  end

  def destroy
    cookies.delete :user_id
    reset_session
    redirect_to home_path, alert: t(".destroy.flash.logout")
  end
end
