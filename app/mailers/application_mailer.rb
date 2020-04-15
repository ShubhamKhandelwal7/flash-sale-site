class ApplicationMailer < ActionMailer::Base
  #FIXME_AB: from email should be env based. Use figaro
  default from: 'from@example.com'
  layout 'mailer'
end
