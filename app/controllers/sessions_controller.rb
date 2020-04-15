class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:user_id] = user.id
      else 
        cookies[:user_id] = user.id
      end
      # TODO: redirect to homepage
      render plain: 'User Logged IN', notice: "Logged in successfully"
    else
      redirect_to login_url, alert: "Incorrect Username/password, please try again"
    end
  end

  def destroy
    cookies[:user_id] = nil
    redirect_to login_url, alert: "Logged out successfully"
  end
end
