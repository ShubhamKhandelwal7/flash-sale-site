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
  validate :ensure_user_address, unless: -> { cart? }
  belongs_to :address, optional: true

  scope :placed_orders, ->{ where.not(state: :cart) }

  def add_items(deal_id)
    #FIXME_AB: Deal.live_deals(Time.current).where(id: deal_id)
    @curr_deal = Deal.live_deals(Time.current).where(id: deal_id)
    if @curr_deal.exists? && @curr_deal.saleable_qty_available? && can_user_buy?
      return true
    end
    false
  end
    
  def place_order
    update_address
    line_items.each do |line_item|
      unless line_item.deal.update_inventory(line_item.quantity)
        return false
      end
    end
    self.state = 'placed'
    update_totals
    save
  end

  private def update_address
    delivery_address = user.addresses.default_address.present? ? user.addresses.default_address.first : user.addresses.last
    self.address_id = delivery_address.id
  end

  private def update_totals
    self.total_amount = line_items.sum(&:sub_total)
    self.total_tax = line_items.sum(&:sub_tax_total)
  end

  #FIXME_AB: shoudl be in Deal model deal.saleable_qty_availabe?  "(quantity - sold_quantity).positive? "

  private def can_user_buy?
    user.ordered_deal_quantity(@curr_deal.id) < ORDERS[:max_deal_quant_per_user]
  end

  private def ensure_user_address
    unless address_id && user.addresses.ids.include?(address_id)
      errors.add(:address_id, "has to be of the user #{user.name}")
    end
  end
end
