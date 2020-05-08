class Order < ApplicationRecord
  enum state: {
    cart: 0,
    placed: 1,
    shipped: 2,
    delivered: 3
  }

  acts_as_paranoid
  has_many :line_items, dependent: :destroy
  has_many :deals, through: :line_items
  belongs_to :user
  #FIXME_AB: cart? method is available due to rails enum
  validate :ensure_user_address, if: -> { state != 'cart' }
  belongs_to :address, optional: true

  scope :placed_orders, ->{ where.not(state: :cart) }

  def add_items(deal_id)
    #FIXME_AB: Deal.live_deals(Time.current).where(id: deal_id)
    @curr_deal = Deal.live_deals(Time.current).find { |deal| deal.id == deal_id }
    # @curr_deal = Deal.find(deal_id)
    if @curr_deal && is_deal_qty_availaible? && can_user_buy?
      return true
    end
    false
  rescue ActiveRecord::RecordNotFound
    false
  end


  #FIXME_AB: shoudl be in Deal model deal.saleable_qty_availabe?  "(quantity - sold_quantity).positive? "
  private def is_deal_qty_availaible?
    @curr_deal.saleable_qty_available?
  end

  private def can_user_buy?
    user.ordered_deal_quantity(@curr_deal.id) < ORDERS[:max_deal_quant_per_user]
  end

  private def ensure_user_address
    unless address_id && user.addresses.ids.include?(address_id)
      errors.add(:address_id, "has to be of the user #{user.name}")
    end
  end
end
