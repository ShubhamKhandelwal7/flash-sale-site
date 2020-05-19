class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def sign_up_verification(user_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: "Welcome to Flash Sale Site" if @user.verified_at.blank?
  end

  def not_verified(user_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: "User coudn't get Verified"
  end

  def password_reset(user_id)
    @user = User.find(user_id)

    mail to: @user.email, subject: "Password Reset"
  end
  
end
