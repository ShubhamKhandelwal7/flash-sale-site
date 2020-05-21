class OrderMailer < ApplicationMailer

  def placed(order_id)
    #FIXME_AB: Order.placed.find..
    #FIXME_AB: check if order is found
    if(@order = Order.find_by(id: order_id))
      @user = @order.user
      mail to: @user.email, subject: "Order Placed"
    end
  end
  
  def refund_intimation(order_id)
    if(@order = Order.find_by(id: order_id))
      @user = @order.user
      mail to: @user.email, subject: "Order Cancelled: Amount Refunded"
    end
  end
end
