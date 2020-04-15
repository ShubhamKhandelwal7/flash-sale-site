class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def sign_up_verification(user)
    @user = user
    #FIXME_AB: send mail if user is not verified
    mail to: @user.email, subject: "Welcome to Flash Sale Site"
  end

  def password_reset(user)
    @user = user

    #FIXME_AB: use mail inceptor https://guides.rubyonrails.org/action_mailer_basics.html#intercepting-and-observing-emails
    #FIXME_AB: to prepend environment in subject, except for production env.
    mail to: @user.email, subject: "Password Reset"
  end
end
