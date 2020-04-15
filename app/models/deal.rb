class PriceValidator < ActiveModel::Validator
  def validate(record)
    return true if record.price && record.price > (record.discount_price || 0)
    record.errors.add(:price, "must be greater than discount price")
  end
end

class Deal < ApplicationRecord
  
  acts_as_paranoid
  has_many_attached :images, dependent: :purge_later

  validates :title, :description, :quantity, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :title, uniqueness: true

  validates_with PriceValidator

end
