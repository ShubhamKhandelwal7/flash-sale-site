class UsersController < ApplicationController
  before_action :authorize

  include UserVerification
  before_action  only: [:verify] do
    current_user_via_token(:verification_token)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.regular.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to login_path, notice: "#{@user.name} #{t("create.flash.success")}" }
      else
        format.html { render :new, notice: "#{@user.name} #{t("create.flash.failure")}" }
      end
    end
  end

  def verify
    if @user.verify
      flash[:notice] = t("verify.flash.success")
    else
      @user.send_not_verified_mail
      #FIXME_AB: flash.now, flash.keep. How flash messages are retained in next request, while other variables not? Read.
      flash[:alert] = t("verify.flash.failure")
    end
    redirect_to login_path
  end

  private def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
