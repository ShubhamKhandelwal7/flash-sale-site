class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        #FIXME_AB: signed cookie. Valid for 14 days.
        cookies.permanent[:user_id] = user.id
      else
        #FIXME_AB: save in session
        #FIXME_AB: read about rails session management in rails and session store.
        cookies[:user_id] = user.id
      end
      # TODO: redirect to homepage
      #FIXME_AB: make a plain dummy controller to redirect
      render plain: 'User Logged IN', notice: "Logged in successfully"
    else
      #FIXME_AB: why login_url not login_path
      redirect_to login_url, alert: "Incorrect Username/password, please try again"
    end
  end

  def destroy
    cookies[:user_id] = nil
    #FIXME_AB: when we save info in session, on logout call "reset_session" helper to clear session. Read about this
    redirect_to login_url, alert: "Logged out successfully"
  end
end
