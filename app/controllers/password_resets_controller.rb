class PasswordResetsController < ApplicationController

  skip_before_action :authorize
  include UserVerification

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
      redirect_to login_path, notice: "Email sent with password reset instructions"
    else
      redirect_to new_password_reset_path , alert: "Email not present in record, please try with email you used to sign-up."
    end
  end

  def update
    reset_request = @user.reset_password(user_params)
    if reset_request[:status]
      redirect_to login_url, notice: "Password reset success"
    elsif !reset_request[:status] && reset_request[:reason] == "update_validation_failed"
      render :edit, notice: "Password couldn't be saved"
    else
      render :new, notice: "Password token expired, please try again"
    end
  end

  private def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
