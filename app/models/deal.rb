#FIXME_AB: move this validator to app/validators folder
class PriceValidator < ActiveModel::Validator
  def validate(record)
    return true if record.price && record.price > (record.discount_price || 0)
    record.errors.add(:price, I18n.t(".errors.discount_price"))
  end
end

#FIXME_AB: move this to app/exceptions
class UnPublishabileError < StandardError
end

class Deal < ApplicationRecord

  acts_as_paranoid
  has_many_attached :images, dependent: :purge_later

  #FIXME_AB: let's add a validation to qty to be > 0 when published_at is present. if not scheduled to publish, we can leave qty validation
  validates :title, :description, :quantity, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :title, uniqueness: true, case_sensitive: false, if: -> { title.present? }
  validate :ensure_min_image_upload

  validates_with PriceValidator

  before_save :ensure_publishability_criteria, if: -> { published_at.present? }
  scope :published_on, ->(date) { where(published_at: date.beginning_of_day..date.end_of_day) }

  def can_be_scheduled_to_publish_on(date)
    #FIXME_AB: need to consider current deal
    valid? && (self.class.published_deals_on(date) < DEALS[:max_deals_per_day].to_i)
  end

  def self.published_deals_on(date)
    published_on(date).count
  end

  def cover_image
    images.first
  end

  private def ensure_min_image_upload
    if images.count < DEALS[:min_images_limit].to_i
      errors.add(:images, "#{I18n.t("errors.image")} #{DEALS[:min_images_limit]}")
    end
  end

  private def ensure_publishability_criteria
    #FIXME_AB: in case of updating the deal which is scheduled to publish on specific day, it will fail
    #FIXME_AB: make a method for every condition can_be_scheduled_to_publish_on?(date) && valid_qty_available? && valid_publish_date_margin

    return if self.class.published_deals_on(published_at) <= (DEALS[:max_deals_per_day].to_i - 1) &&
              quantity >= DEALS[:min_quant_limit].to_i &&
              published_at > (Date.today + 1.day)
    raise UnPublishabileError.new "Publishability criteria failed"
  end

end
