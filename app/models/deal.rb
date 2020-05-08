class Deal < ApplicationRecord

  include BasicPresenter::Concern
  acts_as_paranoid
  #FIXME_AB: we should check the uploaded file should be image only
  has_many_attached :images, dependent: :purge_later
  has_many :line_items, dependent: :restrict_with_error
  has_many :orders, through: :line_items

  validates :title, :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :discount_price, numericality: { only_decimal: true, greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :quantity, numericality: {  greater_than: 0 }, if: -> { published_at.present? }
  validates :title, uniqueness: true, case_sensitive: false, if: -> { title.present? }
  validates :tax, numericality: { only_integer: true }, inclusion: { in: DEALS[:min_tax_allowed]..DEALS[:max_tax_allowed],
             message: "should lie between #{DEALS[:min_tax_allowed]} and #{DEALS[:max_tax_allowed]}"}, allow_nil: true,
             format: { with: REGEXPS[:tax], message: "can have max 4 decimal places" }
  validate :ensure_image_format, if: -> { images.present? }
  validate :ensure_min_image_upload

  validates_with PriceValidator

  before_save :ensure_publishability_criteria, if: -> { published_at.present? }
  scope :published_on, ->(date) { where(published_at: date.beginning_of_day..date.end_of_day) }
  scope :past_live, ->(quantity) { where('published_at < ?', Time.current - 1.day).order(:published_at).last(quantity) }
  scope :live_deals, ->(datetime) { where('live_begin <= :lookup_time AND live_end >= :lookup_time', { lookup_time: datetime }) }

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

  def saleable_qty_available?
    (quantity - sold_quantity).positive?
  end

  private def ensure_image_format
    bad_ext_files = images.blobs.filter {|img| !img[:filename].match(REGEXPS[:image]) }
    if bad_ext_files.present?
      errors.add(:images, "#{(bad_ext_files.collect { |file| file[:filename] }).join(', ')} #{I18n.t("errors.file_format")}")
    end
  end

  private def ensure_min_image_upload
    if images.count < DEALS[:min_images_limit]
      errors.add(:images, "#{I18n.t("errors.image")} #{DEALS[:min_images_limit]}")
    end
  end

  private def ensure_publishability_criteria
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
    existing_user = self.class.find(id) if self.class.exists?(id)
    if existing_user && existing_user.published_at.present?
      if existing_user.published_at.to_date < (Time.current - 1.day) ||
         existing_user.published_at.to_date != published_at.to_date && published_at.to_date < (Date.today + 1.day)
        return false
      end
    elsif published_at.to_date < (Date.today + 1.day)
      return false
    end
    true
  end

end
