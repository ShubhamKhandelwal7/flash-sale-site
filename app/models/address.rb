class Address < ApplicationRecord

  acts_as_paranoid
  has_many :orders, dependent: :restrict_with_error
  belongs_to :user

  before_validation :generate_token

  validates :state, :city, :country, :home_address, presence: :true
  validates :pincode, numericality: { only_integer: true }, length: { is: ADDRESSES[:pincode_length] }
  validates :token, uniqueness: { scope: :user_id, message: I18n.t(".address.errors.not_unique") }

  scope :default_address, -> { where(default: true) }


  def set_default
    user.addresses.default_address.update_all(default: false)
    self.default = true
  end

  private def generate_token
    all_fields = [home_address, state, city, pincode, country].freeze
    self.token = Digest::MD5.hexdigest(all_fields.join)
  rescue StandardError
    I18n.t(".address.errors.md5_token")
  end
end
