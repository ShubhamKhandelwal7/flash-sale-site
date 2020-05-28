json.orders @orders do |order|
  json.number order.number
  json.total_amount order.total_amount
  json.total_tax order.total_tax
  json.state order.state
  if !order.cancelled? && !order.refunded? && !order.cart?
    json.paid_at order.payments.success.first&.paid_at
  elsif order.refunded?
    json.refunded_at order.payments.refunded.first&.refunded_at
  end

  json.delivery_address order&.address, :home_address, :state, :city, :pincode, :country
  json.items order&.line_items do |item|
    json.title item.deal.title
    json.description item.deal.description
    json.quantity item.quantity
    json.price item.price
  end
  json.payments order&.payments do |payment|
    json.transaction_id payment.transaction_id
    json.state payment.state
    json.method payment.method
    json.currency payment.currency
    json.category payment.category
  end
end

