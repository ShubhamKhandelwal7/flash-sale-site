module UserPresence
  extend ActiveSupport::Concern

  #FIXME_AB: we should rename it to 'ensure_not_logged_in'
  def ensure_not_logged_in
    if current_user.present?
      redirect_to home_path, notice: I18n.t(".concerns.user_presence.logged_in")
    end
  end
end
