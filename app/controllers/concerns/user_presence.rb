module UserPresence
  extend ActiveSupport::Concern

  def check_if_logged_in
    if current_user.present?
      redirect_to home_path, notice: I18n.t(".concerns.user_presence.logged_in")
    end
  end
end