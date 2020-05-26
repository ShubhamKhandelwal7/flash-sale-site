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
      #FIXME_AB: include order number in the subject and mail body. In above email also
      mail to: @user.email, subject: "Order #{@order.number}: Cancelled | Amount Refunded"
    end
  end
end
