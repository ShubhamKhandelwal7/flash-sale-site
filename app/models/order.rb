class Order < ApplicationRecord
  #FIXME_AB: use hash
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
  belongs_to :address, optional: true

  #FIXME_AB: don't use string in where condition use where.not(s).where
  #FIXME_AB: don't hardcode 0. state[:cart]

  scope :placed_orders, ->(user) { where.not(state: :cart).where(user_id: user) }

  def add_items(deal_id)
    @curr_deal = Deal.find(deal_id)
    if is_deal_live? && is_deal_qty_availaible? && can_user_buy?
      return true
    end
    false
  rescue ActiveRecord::RecordNotFound
    false
  end

  private def is_deal_live?
    @curr_deal.class.live_deals(Time.current).ids.include? @curr_deal.id
  end

  private def is_deal_qty_availaible?
    original_qty = @curr_deal.quantity
    (original_qty > 0) && (@curr_deal.sold_quantity < original_qty)
  end

  private def can_user_buy?
    User.find(user_id).ordered_deal_quantity(@curr_deal.id) < ORDERS[:max_deal_quant_per_user].to_i
  end
end
