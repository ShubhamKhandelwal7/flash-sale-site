class PasswordResetsController < ApplicationController
  #FIXME_AB: Lets us figaro gem. https://github.com/laserlemon/figaro
  #FIXME_AB: don't commit config/application.yml (.gitignore), add config/application.yml.example in git
  #FIXME_AB: also add database.yml.example file
  RESET_MAIL_VALIDITY_HOURS = 2

  skip_before_action :authorize

  def new
  end

  def edit
    #FIXME_AB: params[:id], params[:token]
    #FIXME_AB: what if user not found with token
    #FIXME_AB: since we are finding user with token in two action, we should make a before_action
    #FIXME_AB: since this before action is needed in two controllers, lets make a controller concern 'user_verification_concern' and use is in both controllers https://api.rubyonrails.org/classes/ActiveSupport/Concern.html
    @user = User.find_by(password_reset_token: params[:id])
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
    @user = User.find_by(password_reset_token: params[:id])

    #FIXME_AB: same like verify. reset_password(p, cp)
    if @user.password_reset_sent_at < RESET_MAIL_VALIDITY_HOURS.hours.ago
      redirect_to :new, notice: "Password token expired, please try again"
    elsif @user.update(user_params)
      redirect_to login_url, notice: "Password reset success"
    else
      render :edit, notice: "Password coudnt be saved"
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
