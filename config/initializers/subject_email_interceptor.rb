class SubjectEmailInterceptor
  def self.delivering_email(message)
    message.subject = "[#{Rails.env}] #{message.subject}"
  end
end

unless Rails.env.production?
  ActionMailer::Base.register_interceptor(SubjectEmailInterceptor)
end