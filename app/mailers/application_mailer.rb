class ApplicationMailer < ActionMailer::Base
  #FIXME_AB: from email should be env based. Use figaro
  default from: ENV["default_from_mail"]
  layout 'mailer'
end
