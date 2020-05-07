class LineItem < ApplicationRecord

  # acts_as_paranoid (as in below valiadtion its considering deleted fields as well, will remove deleted_at column aswell)
  belongs_to :order, optional: true
  belongs_to :deal

  with_options if: -> { order_id.present? } do |line_item|
    line_item.validates :deal_id, uniqueness: { scope: :order_id }
    line_item.validates :quantity, numericality: { less_than_or_equal_to: ORDERS[:max_deal_quant_per_order].to_i }
    line_item.validate :ensure_overall_deal_qty
  end
  #FIXME_AB: need validation on qty. only one qty can be purchased by a user

  def evaluate_amounts
    self.price = deal.price
    calculate_discounts
    calculate_sale_price
    calculate_tax
    calculate_totals
  end
# here total quantity together is being validated, infuture if we limit max quantity for a deal we can check
  private def ensure_overall_deal_qty
    ordered_deal_quant = User.find(order.user_id).ordered_deal_quantity(deal_id)
    if (quantity <= ORDERS[:max_deal_quant_per_order].to_i) && 
       (quantity + ordered_deal_quant) > ORDERS[:max_deal_quant_per_user].to_i
      errors.add(:quantity, "Deal already ordered by user")
    end
  end

  private def calculate_discounts
    self.deal_discount_price = (price - deal.discount_price)
    self.loyalty_discount_price = ((order.user.get_loyalty_discount.to_f/100) * deal_discount_price)
  end

  private def calculate_sale_price
    self.sale_price = (deal_discount_price - loyalty_discount_price)
  end

  private def calculate_tax
    self.taxed_price = ((deal.tax/100) * sale_price)
  end

  private def calculate_totals
    self.sub_total = quantity * (sale_price + taxed_price)
    self.sub_tax_total = quantity * taxed_price
  end

  #FIXME_AB: this should be in user. user.get_loyalty_discount
end


# 10 -> 8 -> 5% -> 10% tax

# - price => 10
# - discounted_price => 8
# - loyality_discount => 8 *%  5 => 0.4
# - sale_price = 8 - 0.4 = 7.6
# - tax = 7.6*10% = 0.76

# -sub_total => (qty) * (sale_price + tax)
# -sub_tax_total => (qty) * (tax)
