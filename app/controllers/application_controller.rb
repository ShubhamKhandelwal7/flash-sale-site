class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :authorize

  #FIXME_AB: why protected, and not private?
  protected

  def authorize
    #FIXME_AB: if user  id is present in session then use that else check for remember me cookie to load user
    if current_user.blank?
      #FIXME_AB: return is redundent
      redirect_to login_path, alert: "Please Login in again"
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id], cookies.signed[:user_id])
  rescue ActiveRecord::RecordNotFound
  end

  #FIXME_AB: make a method current_user which will return the current logged in user
  #FIXME_AB: https://api.rubyonrails.org/classes/AbstractController/Helpers/ClassMethods.html#method-i-helper_method
end
