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
  #FIXME_AB: add a validation that except in cart state order should have address associated with user
  belongs_to :address, optional: true

  #FIXME_AB: remove user
  scope :placed_orders, ->(user) { where.not(state: :cart).where(user_id: user) }

  def add_items(deal_id)
    #FIXME_AB: Deal.live_deals.find
    @curr_deal = Deal.find(deal_id)
    if is_deal_live? && is_deal_qty_availaible? && can_user_buy?
      return true
    end
    false
  rescue ActiveRecord::RecordNotFound
    false
  end

  #FIXME_AB: this is not needed
  private def is_deal_live?
    @curr_deal.class.live_deals(Time.current).ids.include? @curr_deal.id
  end

  #FIXME_AB: shoudl be in Deal model deal.saleable_qty_availabe?  "(quantity - sold_quantity).positive? "
  private def is_deal_qty_availaible?
    original_qty = @curr_deal.quantity
    (original_qty > 0) && (@curr_deal.sold_quantity < original_qty)
  end

  #FIXME_AB: update
  private def can_user_buy?
    User.find(user_id).ordered_deal_quantity(@curr_deal.id) < ORDERS[:max_deal_quant_per_user].to_i
  end
end
