class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :authorize

  private def authorize
    if current_user.blank?
      redirect_to login_path, alert: t("errors.authorize")
    end
  end

  private def current_user
    user_id = session[:user_id] || cookies.signed[:user_id]
    @current_user ||= User.find(user_id)
  rescue ActiveRecord::RecordNotFound
  end

  private def authorize_for_admin
    return if current_user.admin?
    redirect_to login_path, alert: t("errors.admin_authorize")
  end
end
