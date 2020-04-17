class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        #FIXME_AB: lets take this duration from figaro.
        cookies.signed[:user_id] = { value: user.id, expires: ENV["REMEMBER_ME_COOKIE_EXPIRY_DAYS"].to_i.days.from_now }
      else
        #FIXME_AB: read about rails session management in rails and session store. Where is your application saving session, and how would you change your session storate to something else like DB
        session[:user_id] = user.id
      end
      redirect_to dummy_homepage_path, notice: "Logged in successfully"
    else
      redirect_to login_path, alert: "Incorrect Username/password, please try again"
    end
  end

  def destroy
    #FIXME_AB: this is not the right way to expiring cookie
    cookies.delete :user_id
    #FIXME_AB: no need to check session
    reset_session
    redirect_to login_path, alert: "Logged out successfully"
  end
end
