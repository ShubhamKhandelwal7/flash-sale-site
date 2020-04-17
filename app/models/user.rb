class User < ApplicationRecord
  #FIXME_AB: config/initializers/constants.rb. Make a new constant REGEXPS = {email: /fdsafdsa/}, then REGEXPS[:email]

  validates :name, presence: true
  #FIXME_AB: use custom context. on: reset_password
  validates :password,  presence: true, on: :reset_password
  #FIXME_AB: uniqueness with case insensitive.
  validates :email, uniqueness: true, case_sensitive: false, format: {
    with: REGEXPS[:email]
  }

  #FIXME_AB: you should also have uniqueness validation on tokens
  validates :password_reset_token, :verification_token, uniqueness: true

  has_secure_password
  acts_as_paranoid

  before_validation { generate_token(:password_reset_token) }
  before_validation { generate_token(:verification_token) }
  after_commit :send_signup_verification_mail, on: :create, if: -> { admin.blank? }

  #FIXME_AB: users table should have a column admin 'boolean' default false.
  scope :admin, -> { where(admin: true) }

  #FIXME_AB: make another scope. 'regular'
  scope :regular, -> { where(admin: false) }

  def send_password_reset
    generate_token(:password_reset_token)
    #FIXME_AB: Read about the  Time.now and Time.current. We prefer to use Time.current
    self.password_reset_sent_at = Time.current
    #FIXME_AB: bad
    save!
    #FIXME_AB: deliver_later
    UserMailer.password_reset(self.id).deliver_later
  end

  def verify
    if verification_token_sent_at > ENV['VERIFY_MAIL_VALIDITY_HOURS'].to_i.hours.ago
      self.verified_at = Time.current
      self.verification_token = nil
      self.verification_token_sent_at = nil
      save!
    end
  end

  def reset_password(user_params)
    if password_reset_sent_at > ENV['RESET_MAIL_VALIDITY_HOURS'].to_i.hours.ago
      assign_attributes(user_params)
      self.password_reset_token = nil
      self.password_reset_sent_at = nil
      return { status: true } if valid?(:reset_password) && save!
      { status: false, reason: "update_validation_failed"}
    else
      { status: false, reason: "token_expired" }
    end
  end

  #FIXME_AB: we should have a method to check whether user is verified or not 'verified?'
  def verified?
    verified_at.present?
  end

  def send_not_verified_mail
    UserMailer.not_verified(self.id).deliver_later
  end

  private

  def generate_token(column)
    begin
      #FIXME_AB: use self.public_send(column, value)
      token_val = SecureRandom.urlsafe_base64
      self.public_send("#{column}=", token_val)
    rescue StandardError
      ERROR_MSGS[:token]
      #FIXME_AB: public_send
    end while User.exists?(column => token_val)
  end

  def send_signup_verification_mail
    #FIXME_AB: Since you will add admin boolean field, so admin? should work to check whether user is admin or not
    #FIXME_AB: you can add this condition above when registering  callback.
    generate_token(:verification_token)
    self.verification_token_sent_at = Time.now
    save!
    #FIXME_AB: don't pass self, pass the id.
    UserMailer.sign_up_verification(self.id).deliver_later
  end

end
