# == Schema Information
#
# Table name: line_items
#
#  id                     :bigint           not null, primary key
#  quantity               :integer          default(1), not null
#  price                  :decimal(8, 2)
#  deal_discount_price    :decimal(8, 2)
#  loyalty_discount_price :decimal(8, 2)
#  taxed_price            :decimal(8, 2)
#  order_id               :bigint           not null
#  deal_id                :bigint           not null
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  sale_price             :decimal(8, 2)
#  sub_total              :decimal(8, 2)
#  sub_tax_total          :decimal(8, 2)
#
class LineItem < ApplicationRecord

  belongs_to :order, optional: true, counter_cache: true
  belongs_to :deal

  with_options if: -> { order_id.present? } do |line_item|
    line_item.validates :deal_id, uniqueness: { scope: :order_id }
    line_item.validates :quantity, numericality: { less_than_or_equal_to: ORDERS[:max_deal_quant_per_order] }
    line_item.validate :ensure_overall_deal_qty
  end

  before_create :ensure_order_in_cart_state
  before_destroy :ensure_order_in_cart_state
  before_save :evaluate_amounts,  if: -> { order.cart? }


  def evaluate_amounts
    self.price = deal.price
    calculate_discounts
    calculate_sale_price
    calculate_tax
    calculate_totals
  end

  private def ensure_order_in_cart_state
    if !order.cart?
      throw :abort
    end
  end

  private def ensure_overall_deal_qty
    ordered_deal_quant = order.user.ordered_deal_quantity(deal_id)
    if (quantity <= ORDERS[:max_deal_quant_per_order]) && (quantity + ordered_deal_quant) > ORDERS[:max_deal_quant_per_user]
      errors.add(:quantity, I18n.t(".line_item.errors.overall_deal_qty"))
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

end


# 10 -> 8 -> 5% -> 10% tax

# - price => 10
# - discounted_price => 8
# - loyality_discount => 8 *%  5 => 0.4
# - sale_price = 8 - 0.4 = 7.6
# - tax = 7.6*10% = 0.76

# -sub_total => (qty) * (sale_price + tax)
# -sub_tax_total => (qty) * (tax)
