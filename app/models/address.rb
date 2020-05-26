# == Schema Information
#
# Table name: addresses
#
#  id           :bigint           not null, primary key
#  state        :string
#  city         :string
#  pincode      :integer
#  country      :string
#  default      :boolean          default(FALSE), not null
#  user_id      :bigint           not null
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  home_address :text
#  token        :string
#
class Address < ApplicationRecord

  acts_as_paranoid

  validates :state, :city, :country, :home_address, presence: :true
  validates :pincode, numericality: { only_integer: true }, length: { is: ADDRESSES[:pincode_length] }
  #FIXME_AB: we can move this array in initializers so that single array is used. Freeze it. IsoCountryCodes.all.collect &:alpha2
  validates :country, inclusion: { in: IsoCountryCodes.for_select.map{ |x| x[1] }, message: I18n.t(".address.errors.country_code") }
  validates :token, uniqueness: { scope: :user_id, message: I18n.t(".address.errors.not_unique") }

  has_many :orders, dependent: :restrict_with_error
  belongs_to :user

  before_validation :generate_token
  after_save :set_default, if: -> { default? }

  scope :default_address, -> { where(default: true) }


  def set_default
    user.addresses.default_address.update_all(default: false)
    self.update_column(:default, true)
  end

  private def generate_token
    all_fields = [home_address, state, city, pincode, country].freeze
    self.token = Digest::MD5.hexdigest(all_fields.join)
  rescue StandardError
    I18n.t(".address.errors.md5_token")
  end
end
