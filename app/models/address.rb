class Address < ApplicationRecord

  acts_as_paranoid
  has_many :orders, dependent: :restrict_with_error
  belongs_to :user

  #FIXME_AB: add another field 'text area' home_address, where user can add his complete address

  #FIXME_AB: add a validation that user's complete address is unique.
  #FIXME_AB: new field: token. This token is md5 of all fields together
  # validates :token, uniqueness: true scope: user. message: "this is already "
end
