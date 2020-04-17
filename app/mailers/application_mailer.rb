class ApplicationMailer < ActionMailer::Base
  #FIXME_AB: https://github.com/laserlemon/figaro#required-keys
  default from: ENV["default_from_mail"]
  layout 'mailer'
end
