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
  validate :ensure_user_address, unless: -> { cart? }
  belongs_to :address, optional: true

  scope :placed_orders, ->{ where.not(state: :cart) }

  def add_items(deal_id)
    @curr_deal = Deal.live_deals(Time.current).find_by(id: deal_id)
    if @curr_deal.present? && @curr_deal.saleable_qty_available? && can_user_buy?
      #FIXME_AB: return is redundent
      return true
    end
    false
  end

  def place_order
    #FIXME_AB: ensure that order is in cart state
    update_address
    #FIXME_AB: check that item's deal is live
    #FIXME_AB: user can buy items
    line_items.each do |line_item|
      unless line_item.deal.update_inventory(line_item.quantity)
        return false
      end
    end
    #FIXME_AB: self.class.states[:placed]
    self.state = 'placed'
    #FIXME_AB: lets not do update_totals. It shoudl be done before user moves to checkout process
    update_totals
    save
  end

  private def update_address
    delivery_address = user.addresses.default_address.present? ? user.addresses.default_address.first : user.addresses.last
    #FIXME_AB: use self.address = delivery_address
    self.address_id = delivery_address.id
  end

  private def update_totals
    self.total_amount = line_items.sum(&:sub_total)
    self.total_tax = line_items.sum(&:sub_tax_total)
  end

  #FIXME_AB: don't use @curr_deal pass as argument
  private def can_user_buy?
    user.ordered_deal_quantity(@curr_deal.id) < ORDERS[:max_deal_quant_per_user]
  end

  private def ensure_user_address
    unless address_id && user.addresses.ids.include?(address_id)
      errors.add(:address_id, "has to be of the user #{user.name}")
    end
  end
end
