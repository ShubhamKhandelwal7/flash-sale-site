class ApplicationMailer < ActionMailer::Base
  #FIXME_AB: https://github.com/laserlemon/figaro#required-keys
  default from: ENV["DEFAULT_FROM_MAIL"]
  layout 'mailer'
end
