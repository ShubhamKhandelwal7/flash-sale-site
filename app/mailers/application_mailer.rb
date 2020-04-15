class ApplicationMailer < ActionMailer::Base
  default from: ENV["DEFAULT_FROM_MAIL"]
  layout 'mailer'
end
