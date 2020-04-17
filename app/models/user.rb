class User < ApplicationRecord

  validates :name, presence: true
  validates :password,  presence: true, on: :reset_password
  validates :email, uniqueness: true, case_sensitive: false, format: {
    with: REGEXPS[:email]
  }

  validates :password_reset_token, :verification_token, uniqueness: true

  has_secure_password
  acts_as_paranoid

  before_validation { generate_token(:password_reset_token) }
  before_validation { generate_token(:verification_token) }
  #FIXME_AB: after_commit :send_signup_verification_mail, on: :create, unless: -> { admin? }
  after_commit :send_signup_verification_mail, on: :create, if: -> { admin.blank? }

  scope :admin, -> { where(admin: true) }
  scope :regular, -> { where(admin: false) }

  def send_password_reset
    generate_token(:password_reset_token)
    #FIXME_AB: how to set application's timezone
    self.password_reset_sent_at = Time.current
    save!
    UserMailer.password_reset(id).deliver_later
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

  def verified?
    verified_at.present?
  end

  def send_not_verified_mail
    UserMailer.not_verified(id).deliver_later
  end

  private

  def generate_token(column)
    begin
      token_val = SecureRandom.urlsafe_base64
      self.public_send("#{column}=", token_val)
    rescue StandardError
      ERROR_MSGS[:token]
    end while User.exists?(column => token_val)
  end

  def send_signup_verification_mail
    generate_token(:verification_token)
    self.verification_token_sent_at = Time.current
    save!
    UserMailer.sign_up_verification(id).deliver_later
  end

end
