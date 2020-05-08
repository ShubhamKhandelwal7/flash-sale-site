class UsersController < ApplicationController

  include UserPresence
  include UserVerification
  before_action  only: [:verify] do
    current_user_via_token(:verification_token)
  end

  skip_before_action :authorize
  before_action :ensure_not_logged_in

  def new
    @user = User.new
  end

  def create
    @user = User.regular.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to home_path, notice: "#{@user.name} #{t("users.create.flash.success")}" }
      else
        format.html { render :new, notice: "#{@user.name} #{t("users.create.flash.failure")}" }
      end
    end
  end

  def verify
    if @user.verify
      flash[:notice] = t("users.verify.flash.success")
    else
      @user.send_not_verified_mail
      flash[:alert] = t("users.verify.flash.failure")
    end
    redirect_to login_path
  end

  private def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
