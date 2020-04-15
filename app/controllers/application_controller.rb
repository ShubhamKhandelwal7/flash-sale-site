class ApplicationController < ActionController::Base
  before_action :authorize

  protected
  
  def authorize
    unless User.find_by(id: cookies[:user_id])
      return  redirect_to login_url, alert: "Please Login in again"
    end
  end

  def authorize_for_admin
    return if cookies[:user_id].to_i == User.admin.first.id
    redirect_to login_url, notice: "You don't have privilege to access this section"
  end
end
