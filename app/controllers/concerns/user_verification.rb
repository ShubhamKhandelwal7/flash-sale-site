module UserVerification
  extend ActiveSupport::Concern

  # this is used as before action to load user via token
  def current_user_via_token(token_column)
    #FIXME_AB: remove unwanted code
    @user = User.find_by(token_column => params[:token])
    #FIXME_AB: don't raise exception, redirect user to login/home page if user not found with the token
    return if @user.present?
    redirect_to login_path, alert: "Unable to reset/verify user credentials" 
  end

end
