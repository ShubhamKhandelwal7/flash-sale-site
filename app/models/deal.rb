class PriceValidator < ActiveModel::Validator
  def validate(record)
    return true if record.price && record.price > (record.discount_price || 0)
    record.errors.add(:price, I18n.t(".errors.discount_price"))
  end
end

class Deal < ApplicationRecord

  acts_as_paranoid
  has_many_attached :images, dependent: :purge_later

  validates :title, :description, :quantity, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :title, uniqueness: true, case_sensitive: false, if: -> { title.present? }
  validate :ensure_min_image_upload

  validates_with PriceValidator
  scope :published_on, ->(date) { where(published_at: date.beginning_of_day..date.end_of_day) }

  def can_be_scheduled_to_publish_on(date)
    valid? && (self.class.published_deals_on(date) < DEALS[:max_deals_per_day].to_i)
  end

  def self.published_deals_on(date)
    published_on(date).count
  end

  def cover_image
    images.first  
  end

  private def ensure_min_image_upload
    return if images.count >= DEALS[:min_images_limit].to_i
    errors.add(:images, "#{I18n.t("errors.image")} #{DEALS[:min_images_limit]}")
  end

end
