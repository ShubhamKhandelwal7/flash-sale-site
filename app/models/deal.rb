# == Schema Information
#
# Table name: deals
#
#  id             :bigint           not null, primary key
#  title          :citext           not null
#  description    :text
#  price          :decimal(8, 2)
#  discount_price :decimal(8, 2)    default(0.0), not null
#  quantity       :integer          default(0), not null
#  published_at   :datetime
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  live_begin     :datetime
#  live_end       :datetime
#  tax            :decimal(, )
#  sold_quantity  :integer          default(0), not null
#  lock_version   :integer          default(0), not null
#
class Deal < ApplicationRecord

  include BasicPresenter::Concern
  acts_as_paranoid


  validates :title, :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :discount_price, numericality: { only_decimal: true, greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :quantity, numericality: {  greater_than: 0 }, if: -> { published_at.present? }
  validates :title, uniqueness: true, case_sensitive: false, if: -> { title.present? }
  validates :tax, numericality: { only_decimal: true }, inclusion: { in: DEALS[:min_tax_allowed]..DEALS[:max_tax_allowed],
             message: "should lie between #{DEALS[:min_tax_allowed]} and #{DEALS[:max_tax_allowed]}"}, allow_nil: true,
             format: { with: REGEXPS[:tax], message: "can have max 4 decimal places" }
  validate :ensure_image_format, if: -> { images.present? }
  validate :ensure_min_image_upload

  validates_with PriceValidator

  has_many_attached :images, dependent: :purge_later
  has_many :line_items, dependent: :restrict_with_error
  has_many :orders, through: :line_items

  before_save :ensure_publishability_criteria, if: -> { published_at.present? }
  scope :published_on, ->(date) { where(published_at: date.beginning_of_day..date.end_of_day) }
  scope :past_live, ->(quantity) { where('published_at < ?', Time.current - 1.day).order(:published_at).last(quantity) }
  scope :live_deals, ->(datetime) { where('live_begin <= :lookup_time AND live_end >= :lookup_time', { lookup_time: datetime }) }
  scope :past_deals, ->(datetime) { where("live_end < ?", datetime) }

  def can_be_scheduled_to_publish_on(date)
    #FIXME_AB: need to consider current deal
    if published_at&.to_date == date
      return true
    end
    valid? && (self.class.published_deals_on(date) < DEALS[:max_deals_per_day]) &&
    (date > Date.today + 1.day)
  end

  def self.published_deals_on(date)
    published_on(date).count
  end

  def live?
    self.class.live_deals(Time.current).exists? self.id
  end

  def live!
    if published_at&.today?
      time_now = Time.current
      update_columns(live_begin: time_now, live_end: time_now + ENV["DEAL_LIVE_DAYS"].to_i.day)
    end
  end

  def saleable_qty_available?
    salebale_qty.positive?
  end

  def salebale_qty
    quantity - sold_quantity
  end

  def check_inventory(qty_bought)
    saleable_qty_available? && qty_bought <= salebale_qty
  end

  def update_inventory(qty_bought)
    if check_inventory(qty_bought)
      sold_quantity = self.sold_quantity + qty_bought
      self.update_columns(sold_quantity: sold_quantity, lock_version: lock_version + 1, updated_at: Time.current)
    else
      false
    end
  rescue StandardError
    false
  end

  def publish(date)
    publish_on_date = Date.parse(date)
    if publish_on_date.present? && can_be_scheduled_to_publish_on(publish_on_date)
      self.published_at = publish_on_date
      save
    else
      false
    end
  rescue StandardError
    false
  end

  def can_be_rescheduled? # or we can do .save? {ensure_publishability_criteria}
    published_at && published_at > Time.current + ENV['PUBLISH_DEAL_RESTRICT_TIME'].to_i.day && !live?
  end

  def can_be_updated?
    published_at.blank? || can_be_rescheduled?
  end

  def unpublish
    if can_be_rescheduled?
      self.published_at = nil
      save
    else
      false
    end
  end

  private def ensure_image_format
    if images.any? { |img| !img.image? }
      errors.add(:images, "#{I18n.t("errors.file_format")}")
    end
  end

  private def ensure_min_image_upload
    if images.count < DEALS[:min_images_limit]
      errors.add(:images, "#{I18n.t("errors.image")} #{DEALS[:min_images_limit]}")
    end
  end

  private def ensure_publishability_criteria
    #FIXME_AB: we should also check that if publish_at is changed then its previous publish date should not be in past day

    #FIXME_AB: in case of updating the deal which is scheduled to publish on specific day, it will fail
    #FIXME_AB: make a method for every condition can_be_scheduled_to_publish_on?(date) && valid_qty_available? && valid_publish_date_margin
    unless can_be_scheduled_to_publish_on? && valid_qty_availaible? && is_tax_present? && valid_publish_date_margin?
    raise UnPublishableError.new "Publishability criteria failed"
    end
  end


  private def can_be_scheduled_to_publish_on?
    if self.class.exists?(id) && self.class.find(id).published_at&.to_date == published_at.to_date
      current_published_deal =  1
    end
    self.class.published_deals_on(published_at) - (current_published_deal || 0) <= (DEALS[:max_deals_per_day] - 1)
  end

  private def is_tax_present?
    tax.present?
  end

  private def valid_qty_availaible?
    quantity >= DEALS[:min_quant_limit]
  end

   private def valid_publish_date_margin?
    existing_deal = self.class.find_by(id: id)
    if existing_deal&.published_at&.present?
      if existing_deal.published_at.to_date <= (Time.current + ENV['PUBLISH_DEAL_RESTRICT_TIME'].to_i.day).to_date ||
         existing_deal.published_at.to_date != published_at.to_date && published_at.to_date < (Date.today + 1.day)
        return false
      end
    elsif published_at.to_date < (Date.today + 1.day)
      return false
    end
    true
  end

end
