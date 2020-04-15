class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :authorize

  private def authorize
    if current_user.blank?
      redirect_to login_path, alert: "Please Login in again"
    end
  end

  private def current_user
    user_id = session[:user_id] || cookies.signed[:user_id]
    @current_user ||= User.find(user_id)
  rescue ActiveRecord::RecordNotFound
  end

  private def authorize_for_admin
    return if current_user.admin
    redirect_to login_path, alert: "You don't have privilege to access this section"
  end
end
