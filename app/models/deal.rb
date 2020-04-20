class PriceValidator < ActiveModel::Validator
  def validate(record)
    return true if record.price && record.price > (record.discount_price || 0)
    record.errors.add(:price, I18n.t(".errors.discount_price"))
  end
end

class Deal < ApplicationRecord

  acts_as_paranoid
  has_many_attached :images, dependent: :purge_later

  validates :title, :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :title, uniqueness: true, case_sensitive: false, if: -> { title.present? }
  validates :quantity, presence: true, numericality: { greater_than: DEALS[:min_quant_limit].to_i }
  validate :ensure_min_image_upload

  validates_with PriceValidator
  scope :published_on, ->(date) { where('date(published_at) = ?', date.to_s) }

  def publishable?
    return true if valid? && (published_deals_today < DEALS[:max_deals_per_day].to_i)
    false
  end

  private def published_deals_today
    Deal.published_on(Time.current).count
  end

  private def ensure_min_image_upload
    return if images.count >= DEALS[:min_images_limit].to_i
    errors.add(:images, "#{I18n.t("errors.image")} #{DEALS[:min_images_limit]}")
  end

end
