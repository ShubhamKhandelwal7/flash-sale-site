class LineItem < ApplicationRecord

  # acts_as_paranoid (as in below valiadtion its considering deleted fields as well, will remove deleted_at column aswell)
  belongs_to :order, optional: true
  belongs_to :deal

  validates :deal_id, uniqueness: { scope: :order_id }, if: -> { order_id.present? }

  def evaluate_discounts
    calculate_deal_discount
    calculate_loyalty_discount
    calculate_tax
  end

  private def calculate_deal_discount
    self.deal_discount_price = (deal.price - deal.discount_price)
  end

  private def calculate_loyalty_discount
    no_of_orders = order.class.placed_orders(order.user.id).count
    if no_of_orders > 0
      self.loyalty_discount_price = get_loyalty_discount(no_of_orders.count)
    else
      self.loyalty_discount_price = deal_discount_price
    end
  end

  private def calculate_tax
    self.taxed_price = loyalty_discount_price + (deal.tax/100 * deal.price)
  end

  private def get_loyalty_discount(orders_count)
    orders_count = 5 if orders_count >= 5
    deal_discount_price - ((orders_count/100) * deal_discount_price)
  end
end