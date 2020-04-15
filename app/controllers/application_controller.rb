class ApplicationController < ActionController::Base
  before_action :authorize

  protected
  
  def authorize
    unless User.find_by(id: cookies[:user_id])
      return  redirect_to login_url, alert: "Please Login in again"
    end
  end
end
