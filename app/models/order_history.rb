class OrderHistory < ApplicationRecord
  enum state: {
    cart: 0,
    paid: 1,
    placed: 2,
    shipped: 3,
    delivered: 4,
    cancelled: 5,
    refunded: 6
  }

  belongs_to :order

  scope :shipped, -> { where(state: :shipped) }
  scope :delivered, -> { where(state: :delivered) }
  scope :cancelled, -> { where(state: :cancelled).or where(state: :refunded) }
  
end