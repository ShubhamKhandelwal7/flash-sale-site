class PasswordResetsController < ApplicationController

  include UserVerification
  include UserPresence

  skip_before_action :authorize
  #FIXME_AB: we should ensure that user is not logged in
  
  before_action :ensure_not_logged_in
  before_action  only: [:edit, :update] do
    current_user_via_token(:password_reset_token)
  end

  def new
  end

  def edit
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      user.send_password_reset
      redirect_to login_path, notice: t("create.flash.success")
    else
      redirect_to new_password_reset_path , alert: t("create.flash.failure")
    end
  end

  def update
    reset_request = @user.reset_password(user_params)
    if reset_request[:status]
      redirect_to login_url, notice: t("update.flash.success")
    elsif !reset_request[:status] && reset_request[:reason] == "update_validation_failed"
      render :edit, alert: t("update.flash.failure.message")
    else
      render :new, alert: t("update.flash.failure.tokenexpire")
    end
  end

  private def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
