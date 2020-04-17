class UsersController < ApplicationController
  before_action :authorize
  #FIXME_AB: figaro

  include UserVerification
  before_action  only: [:verify] do
    current_user_via_token(:verification_token)
  end
  
  def new
    @user = User.new
  end

  def create

    #FIXME_AB: User.regular.new
    @user = User.regular.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to login_path, notice: "#{@user.name} successfully created" }
      else
        format.html { render :new, notice: "#{@user.name} not got created" }
      end
    end
  end

  def verify
    if @user.verify
      flash[:notice] = "User successfully verified"
    else
      @user.send_not_verified_mail
      flash[:alert] = "User could not got verified"
    end
    redirect_to login_path
  end
    #FIXME_AB: use like this: "if user.verify". 1. check if token is valid. 2. set verified_at 3. clear verification token and date

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
