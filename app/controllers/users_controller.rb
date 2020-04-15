class UsersController < ApplicationController
  VERIFY_MAIL_VALIDITY_HOURS = 5

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to login_url, notice: "#{@user.name} successfully created" }
      else
        format.html { render :new, notice: "#{@user.name} not got created" }
      end
    end
  end

  def verify
    user = User.find_by_verification_token(params[:id])

    if user.verification_token_sent_at > VERIFY_MAIL_VALIDITY_HOURS.hours.ago
      user.update_column(:verified_at, Time.now)
      flash[:notice] = "User successfully verified" 
    else
      flash[:alert] = "User could not got verified" 
    end
    redirect_to login_url
  end

  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
