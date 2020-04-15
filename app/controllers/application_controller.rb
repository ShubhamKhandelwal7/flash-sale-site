class ApplicationController < ActionController::Base
  before_action :authorize

  #FIXME_AB: why protected, and not private?
  protected

  def authorize
    #FIXME_AB: if user  id is present in session then use that else check for remember me cookie to load user
    unless User.find_by(id: cookies[:user_id])
      #FIXME_AB: return is redundent
      return  redirect_to login_url, alert: "Please Login in again"
    end
  end

  #FIXME_AB: make a method current_user which will return the current logged in user
  #FIXME_AB: https://api.rubyonrails.org/classes/AbstractController/Helpers/ClassMethods.html#method-i-helper_method
end
