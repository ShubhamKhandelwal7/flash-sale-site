json.orders @orders do |order|
  json.number order.number
  json.total_amount order.total_amount
  json.total_tax order.total_tax
  json.state order.state
  json.delivery_address order&.address, :home_address, :state, :city, :pincode, :country
  json.payments order&.payments do |payment|
    json.transaction_id payment.transaction_id
    json.state payment.state
    json.method payment.method
    json.currency payment.currency
    json.category payment.category
  end
end

