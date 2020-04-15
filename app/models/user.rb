class User < ApplicationRecord
  EMAIL_REGEX = /\A[^@\s]+@[-a-z0-9]+\.+[a-z]{2,}\z/i
  TOKEN_ERROR_MSG = "Secure Token could not be generated"

  validates :name, presence: true
  validates :password,  presence: true, on: :update
  validates :email, uniqueness: true, format: {
    with: EMAIL_REGEX
  }

  before_create { generate_token(:password_reset_token) }
  after_commit :send_verification_mail, on: :create
  has_secure_password
  acts_as_paranoid
  scope :admin, -> { where(email: 'admin01@gmail.com') }


  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.now
    save!(validate: false)
    UserMailer.password_reset(self).deliver
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    rescue StandardError
      TOKEN_ERROR_MSG
    end while User.exists?(column => self[column])
  end

  def send_verification_mail
    return if self == User.admin.first
    generate_token(:verification_token)
    self.verification_token_sent_at = Time.now
    save!
    UserMailer.sign_up_verification(self).deliver_later
  end

end
