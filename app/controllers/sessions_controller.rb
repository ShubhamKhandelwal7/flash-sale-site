class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.signed[:user_id] = { value: user.id, expires: ENV["REMEMBER_ME_COOKIE_EXPIRY_DAYS"].to_i.days.from_now }
      else
        #FIXME_AB: read about rails session management in rails and session store. Where is your application saving session, and how would you change your session storate to something else like DB
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
