module UserPresence
  extend ActiveSupport::Concern

  def check_if_logged_in
    #FIXME_AB: lets now avoid using inline if-unless
    #FIXME_AB: whenever we do redirect, add flash message
    redirect_to home_path if current_user.present?
  end
end
