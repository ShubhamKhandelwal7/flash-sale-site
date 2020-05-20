class OrderMailer < ApplicationMailer

  def placed(order_id)
    #FIXME_AB: Order.placed.find..
    #FIXME_AB: check if order is found
    @order = Order.find_by(id: order_id)
    @user = @order.user

    mail to: @user.email, subject: "Order Placed"
  end
end
