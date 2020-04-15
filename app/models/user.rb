class User < ApplicationRecord
  #FIXME_AB: config/initializers/constants.rb. Make a new constant REGEXPS = {email: /fdsafdsa/}, then REGEXPS[:email]
  EMAIL_REGEX = /\A[^@\s]+@[-a-z0-9]+\.+[a-z]{2,}\z/i
  TOKEN_ERROR_MSG = "Secure Token could not be generated"

  validates :name, presence: true
  #FIXME_AB: use custom context. on: reset_password
  validates :password,  presence: true, on: :update
  #FIXME_AB: uniqueness with case insensitive.
  validates :email, uniqueness: true, format: {
    with: EMAIL_REGEX
  }

  #FIXME_AB: you should also have uniqueness validation on tokens

  has_secure_password
  acts_as_paranoid

  before_create { generate_token(:password_reset_token) }
  after_commit :send_signup_verification_mail, on: :create

  #FIXME_AB: users table should have a column admin 'boolean' default false.
  scope :admin, -> { where(email: 'admin01@gmail.com') }

  #FIXME_AB: make another scope. 'regular'


  def send_password_reset
    generate_token(:password_reset_token)
    #FIXME_AB: Read about the  Time.now and Time.current. We prefer to use Time.current
    self.password_reset_sent_at = Time.now
    #FIXME_AB: bad
    save!(validate: false)
    #FIXME_AB: deliver_later
    UserMailer.password_reset(self).deliver
  end

  #FIXME_AB: we should have a method to check whether user is verified or not 'verified?'

  private

  def generate_token(column)
    begin
      #FIXME_AB: use self.public_send(column, value)
      self[column] = SecureRandom.urlsafe_base64
    rescue StandardError
      TOKEN_ERROR_MSG
      #FIXME_AB: public_send
    end while User.exists?(column => self[column])
  end

  def send_signup_verification_mail
    #FIXME_AB: Since you will add admin boolean field, so admin? should work to check whether user is admin or not
    #FIXME_AB: you can add this condition above when registering  callback.
    return if self == User.admin.first
    generate_token(:verification_token)
    self.verification_token_sent_at = Time.now
    save!
    #FIXME_AB: don't pass self, pass the id.
    UserMailer.sign_up_verification(self).deliver_later
  end

end
