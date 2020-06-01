# == Schema Information
#
# Table name: orders
#
#  id               :bigint           not null, primary key
#  total_amount     :decimal(, )
#  total_tax        :decimal(, )
#  address_id       :bigint
#  user_id          :bigint           not null
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  state            :integer          default("cart"), not null
#  line_items_count :integer
#  placed_at        :datetime
#
class Order < ApplicationRecord
  enum state: {
    cart: 0,
    paid: 1,
    placed: 2,
    shipped: 3,
    delivered: 4,
    cancelled: 5,
    refunded: 6
  }

  acts_as_paranoid
  define_model_callbacks :place_order, :mark_shipped, :mark_delivered, :mark_cancelled, only: :after

  validate :ensure_user_address, :ensure_payment_made, if: -> { placed? || shipped? || delivered? }
  validates :line_items_count, numericality: { greater_than: 0 }, if: -> { placed? }
  validate :ensure_state_transition, if: -> { state_change }

  has_many :line_items, dependent: :destroy
  has_many :deals, through: :line_items
  has_many :payments, dependent: :destroy
  has_many :order_histories, dependent: :destroy
  belongs_to :user
  belongs_to :address, optional: true

  after_place_order :send_placed_mailer
  after_mark_shipped :state_shipped
  after_mark_delivered :state_delivered
  after_mark_cancelled :state_cancelled

  scope :placed_orders, ->{ where(state: :placed).or where(state: :shipped).or where(state: :delivered) }
  scope :paid_orders, -> { where.not(state: :cart) }
  scope :shipped, -> { where(state: :shipped) }
  scope :delivered, -> { where(state: :delivered) }

  def number
   "#{(placed_at || created_at).to_s(:number)}-#{id}"
  end

  def add_item(deal_id)
    deal = Deal.live_deals(Time.current).find_by(id: deal_id)
    deal.present? && deal.saleable_qty_available? && can_user_buy?(deal.id) && (item = line_items.create(deal: deal, quantity: LINEITEMS[:default_quantity])) && item.persisted?
  end

  def remove_item(line_item_id)
    line_items.find_by(id: line_item_id)&.destroy
  end

  def place_order
    run_callbacks :place_order do
      unless paid?
        return false
      end

      line_items.includes(:deal).each do |line_item|
        unless line_item.deal.live? || can_user_buy?(line_item.deal_id) || line_item.deal.check_inventory(line_item.quantity)
          return false
        end
      end

      transaction do
        if update_inventory
          self.state = self.class.states[:placed]
          self.placed_at = Time.current
          save! && order_histories.create(state: state, note: "Order Placed")
        else
          raise StandardError.new "Update Inventory Failure"
          return false
        end
      end
    rescue StandardError
      logger.tagged("Order: payments[refund]") do
        if process_refunds
          logger.info { "Order state changed to: #{state}, sending refund_intimation mailer" }
          OrderMailer.refund_intimation(id).deliver_later
        end
      end
    false
    end
  end


  def process_refunds
    if payments.success.map(&:refund).all?{ |refund_status| refund_status}
      logger.info { "Refund process success, updating order state to refund state" }
      order_histories.create(state: state, note: "Refund success")
      update(state: self.class.states[:refunded])
    else
      logger.info { "some payments could not be refunded" }
    end
  end

  def set_address!(address)
    self.address = address
    save
  end

  def update_totals
    self.total_amount = line_items.sum(&:sub_total)
    self.total_tax = line_items.sum(&:sub_tax_total)
  end

  def make_payment(token)
    logger.info { "initiating make_payment method against order id: #{id}, calling stripe_transact after checks & building payment" }
    paid = self.class.states[:paid]
    cart? && address && payments.build.stripe_transact(token) && update(state: paid) && order_histories.create(state: paid, note: "Payment success")
  end

  def mark_as_shipped!(note)
    run_callbacks :mark_shipped do
      self.state = Order.states[:shipped]
      save && (event = order_histories.create(state: state, note: note)) && event.persisted?
    end
  end

  def mark_as_delivered!(note)
    run_callbacks :mark_delivered do
      self.state = Order.states[:delivered]
      save && (event = order_histories.create(state: state, note: note)) && event.persisted?
    end
  end

  def mark_as_cancelled!(note)
    run_callbacks :mark_cancelled do
      self.state = Order.states[:cancelled]
      save && process_refunds && (event = order_histories.create(state: state, note: note)) && event.persisted?
    end
  end
  
  private def state_shipped
    if shipped?
      OrderMailer.shipped(id).deliver_later
    end
  end

  private def state_delivered
    if delivered?
      OrderMailer.delivered(id).deliver_later
    end
  end

  private def state_cancelled
    if refunded?
      OrderMailer.refund_intimation(id).deliver_later
    end
  end

  private def ensure_state_transition
    if !(STATE_TRASITIONS[state_was].include?(state))
      errors.add(:state, "transition from #{state_was} to #{state} is not allowed")
    end
  end

  private def update_inventory
    line_items.each do |line_item|
      unless line_item.deal.update_inventory(line_item.quantity)
        return false
      end
    end
    true
  end

  private def can_user_buy?(deal_id)
    user.ordered_deal_quantity(deal_id) < ORDERS[:max_deal_quant_per_user]
  end

  private def ensure_user_address
    unless address_id && user.addresses.ids.include?(address_id)
      errors.add(:address_id, "has to be of the user #{user.name}")
    end
  end

  private def ensure_payment_made
    if payments.success.blank?
      errors.add(:payment, "no payment with state as succeeded exists")
    end
  end

  private def send_placed_mailer
    if placed?
      OrderMailer.placed(id).deliver_later
    end
  end
end
