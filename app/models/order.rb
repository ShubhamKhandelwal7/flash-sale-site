class Order < ApplicationRecord
  #FIXME_AB: use hash
  enum state: [:cart, :placed, :shipped, :delivered]

  acts_as_paranoid
  has_many :line_items, dependent: :destroy
  has_many :deals, through: :line_items
  belongs_to :user
  belongs_to :address, optional: true

  #FIXME_AB: don't use string in where condition use where.not(s).where
  #FIXME_AB: don't hardcode 0. state[:cart]

  scope :placed_orders, ->(user) { where("state != 0 AND user_id = ?", user) }
end
