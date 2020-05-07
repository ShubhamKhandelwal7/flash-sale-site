class Address < ApplicationRecord

  acts_as_paranoid
  has_many :orders, dependent: :restrict_with_error
  belongs_to :user

  before_validation :generate_token

  validates :state, :city, :country, :home_address, presence: :true
  validates :pincode, numericality: { only_integer: :true }, length: { is: ADDRESSES[:pincode_length].to_i }
  validates :token, uniqueness: { scope: :user_id, message: I18n.t(".address.errors.not_unique") }

  #FIXME_AB: add another field 'text area' home_address, where user can add his complete address

  #FIXME_AB: add a validation that user's complete address is unique.
  #FIXME_AB: new field: token. This token is md5 of all fields together
  # validates :token, uniqueness: true scope: user. message: "this is already "

  private def generate_token
    all_fields = [home_address, state, city, pincode, country].freeze
    self.token = Digest::MD5.hexdigest(all_fields.join)
  rescue StandardError
    ERROR_MSGS[:md5_token]
  end
end
