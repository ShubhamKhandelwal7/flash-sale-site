class Address < ApplicationRecord

  acts_as_paranoid
  has_many :orders, dependent: :restrict_with_error
  belongs_to :user
end