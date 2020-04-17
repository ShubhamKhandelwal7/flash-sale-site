class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :authorize

  private def authorize
    if current_user.blank?
      redirect_to login_path, alert: "Please Login in again"
    end
  end

  private def current_user
    #FIXME_AB: user_id = session[:user_id] || cookies.signed[:user_id]
    user_id = session[:user_id] || cookies.signed[:user_id]
    @current_user ||= User.find(user_id)
  rescue ActiveRecord::RecordNotFound
  end

end
