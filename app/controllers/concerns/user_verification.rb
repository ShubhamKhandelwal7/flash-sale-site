module UserVerification
  extend ActiveSupport::Concern

  # this is used as before action to load user via token
  def current_user_via_token(token_column)
    @user = User.find_by(token_column => params[:token])
    return if @user.present?
    redirect_to login_path, alert: "Unable to reset/verify user credentials"
  end

end
