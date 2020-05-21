class Order < ApplicationRecord
  #FIXME_AB: canceled, refunded state
  enum state: {
    cart: 0,
    placed: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4,
    refunded: 5 
  }

  acts_as_paranoid
  define_model_callbacks :place_order, only: :after

  validate :ensure_user_address, :ensure_payment_made, if: -> { placed? || shipped? || delivered? }
  validates :line_items_count, numericality: { greater_than: 0 }, if: -> { placed? }
  validate :ensure_state_transition, if: -> { state_change }

  has_many :line_items, dependent: :destroy
  has_many :deals, through: :line_items
  has_many :payments, dependent: :destroy
  belongs_to :user
  belongs_to :address, optional: true

  after_place_order :send_mailer

  scope :placed_orders, ->{ where.not(state: :cart) }

  #FIXME_AB: we need to add validations for order state changes. like from which states to which state. Read about state machines, we usually do use that gem https://github.com/geekq/workflow
  # STATE_TRASITIONS = {
  #   cart: [:placed],
  #   placed: [:shipped, :cancelled],
  #   ...

  # }


  # def add_item(deal_id)
  #   deal = Deal.live_deals(Time.current).find_by(id: deal_id)

  #   if deal.present? && deal.saleable_qty_available? && can_user_buy?(deal.id)
  #     #FIXME_AB:  line_item = line_items.build(deal: @curr_deal)
  #     line_item = line_items.build
  #     line_item.deal = deal
  #     line_item.evaluate_amounts
  #     #FIXME_AB: you should also save the line item so that the method returns true/false
  #     line_item
  #   else
  #     false
  #   end
  # end

  def add_item(deal_id)
    deal = Deal.live_deals(Time.current).find_by(id: deal_id)
    deal.present? && deal.saleable_qty_available? && can_user_buy?(deal.id) && (item = line_items.create(deal: deal, quantity: LINEITEMS[:default_quantity])) && item.persisted?
  end

  def remove_item(line_item_id)
    line_items.find_by(id: line_item_id)&.destroy
  end

  #FIXME_AB: lets use custom callbacks after place_order, which will send order placed or refund email based on the status of the order
  def place_order
    run_callbacks :place_order do
      unless cart?
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
          save!
        else
          #FIXME_AB: raise an exception
          raise StandardError.new "Update Inventory Failure"
          return false
        end
      end
    end
  rescue StandardError
    logger.tagged("Order: payments[refund]") do
      if process_refunds
        logger.info { "Order state changed to: #{state}, sending refund_intimation mailer" }
      end
      # mail not sending in this case
      #FIXME_AB: refund amount and notify user
    end
  false
  end

  def process_refunds
    if (success_pay = payments.success.first) && payments.build.refund(success_pay.transaction_id)
      logger.info { "Refund process success, updating success payment to cancelled" }
      prev_success_payment = payments.success.first
      prev_success_payment.state = Payment.states[:cancelled]
      prev_success_payment.save
      self.state = self.class.states[:refunded]
      save
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
    #FIXME_AB:  logging
    logger.info { "initiating make_payment method against order id: #{id}, calling stripe_transact after checks & building payment" }
    cart? && address && payments.build.stripe_transact(token)
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

  private def send_mailer
    if placed?
      OrderMailer.placed(id).deliver_later
    elsif refunded?
      OrderMailer.refund_intimation(id).deliver_later
    end
  end
end
