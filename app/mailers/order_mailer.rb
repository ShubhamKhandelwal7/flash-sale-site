class OrderMailer < ApplicationMailer

  def placed(order_id)
    if(@order = Order.placed.find_by(id: order_id))
      @user = @order.user
      mail to: @user.email, subject: "Order #{@order.number}: Placed"
    end
  end

  def refund_intimation(order_id)
    if(@order = Order.find_by(id: order_id))
      @user = @order.user
      mail to: @user.email, subject: "Order #{@order.number}: Cancelled | Amount Refunded"
    end
  end

  def delivered(order_id)
    #FIXME_AB: delivered
    if(@order = Order.placed_orders.find_by(id: order_id))
      @user = @order.user
      mail to: @user.email, subject: "Order #{@order.number}: Delivered"
    end
  end
end
