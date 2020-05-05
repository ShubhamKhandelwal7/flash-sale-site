class LineItem < ApplicationRecord

  # acts_as_paranoid (as in below valiadtion its considering deleted fields as well, will remove deleted_at column aswell)
  belongs_to :order, optional: true
  belongs_to :deal

  validates :deal_id, uniqueness: { scope: :order_id }, if: -> { order_id.present? }
  #FIXME_AB: need validation on qty. only one qty can be purchased by a user

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

  #FIXME_AB: this should be in user. user.get_loyalty_discount
  private def get_loyalty_discount(orders_count)
    orders_count = 5 if orders_count >= 5
    deal_discount_price - ((orders_count/100) * deal_discount_price)
  end
end


# 10 -> 8 -> 5% -> 10% tax

# - price => 10
# - discounted_price => 8
# - loyality_discount => 8 *%  5 => 0.4
# - sale_price = 8 - 0.4 = 7.6
# - tax = 7.6*10% = 0.76

# -sub_total => (qty) * (sale_price + tax)
# -sub_tax_total => (qty) * (tax)
