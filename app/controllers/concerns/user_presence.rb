module UserPresence
  extend ActiveSupport::Concern

  def check_if_logged_in
    redirect_to home_path if current_user.present?
  end
end