class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def sign_up_verification(user)
    @user = user
    mail to: @user.email, subject: "Welcome to Flash Sale Site"  
  end

  def password_reset(user)
    @user = user
    mail to: @user.email, subject: "Password Reset"
  end
end
