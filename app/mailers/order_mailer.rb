class OrderMailer < ApplicationMailer

  def placed(order_id)
    @order = Order.find_by(id: order_id)
    @user = @order.user

    mail to: @user.email, subject: "Order Placed"
  end
end