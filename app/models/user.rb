class User < ApplicationRecord

  validates :name, presence: true
  validates :password,  presence: true, on: :reset_password
  validates :password, length: { minimum: USERS[:min_password_length].to_i }
  validates :password, format: { with: REGEXPS[:password], message: I18n.t(".users.errors.password") }
  validates :email, uniqueness: true, case_sensitive: false, format: {
    with: REGEXPS[:email]
  }

  validates :password_reset_token, :verification_token, uniqueness: true

  has_secure_password
  acts_as_paranoid
  has_many :addresses, dependent: :destroy
  #FIXME_AB: we should not allow user to be deleted if any of his order exists in non cart state
  has_many :orders, dependent: :destroy
  has_many :line_items, through: :orders

  before_validation { generate_token(:password_reset_token) }
  before_validation { generate_token(:verification_token) }

  before_destroy :ensure_order_not_placed
  after_commit :send_signup_verification_mail, on: :create, unless: -> { admin? }

  scope :admin, -> { where(admin: true) }
  scope :regular, -> { where(admin: false) }

  def send_password_reset
    generate_token(:password_reset_token)
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
      if valid?(:reset_password) && save!
        return { status: true }
      end
      { status: false, reason: "update_validation_failed"}
    else
      { status: false, reason: "token_expired" }
    end
  end

  def verified?
    verified_at.present?
  end

  def ordered_deal_quantity(deal_id)
    all_orders = Order.where(user_id: id)
    total_deal_quantity = 0
    all_orders.each do |order|
      order.line_items.where(deal_id: deal_id).each do |line|
        total_deal_quantity += line.quantity
      end
    end
    total_deal_quantity
  end

  def get_loyalty_discount
    orders_count = Order.placed_orders(id).count
    if orders_count >= USERS[:max_orders_count_for_discount].to_i
      orders_count = USERS[:max_orders_count_for_discount].to_i
    end
    orders_count
  end

  def send_not_verified_mail
    UserMailer.not_verified(id).deliver_later
  end

  private def generate_token(column)
    begin
      token_val = SecureRandom.urlsafe_base64
      self.public_send("#{column}=", token_val)
    rescue StandardError
      ERROR_MSGS[:token]
    end while User.exists?(column => token_val)
  end

  private def send_signup_verification_mail
    generate_token(:verification_token)
    self.verification_token_sent_at = Time.current
    save!
    UserMailer.sign_up_verification(id).deliver_later
  end

  private def ensure_order_not_placed
    if orders.where.not(state: :cart).present?
      throw :abort
    end
  end

end
