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
      @order_notes = @order.order_histories.order(created_at: :desc).cancelled
      mail to: @user.email, subject: "Order #{@order.number}: Cancelled | Amount Refunded"
    end
  end

  def delivered(order_id)
    if(@order = Order.delivered.find_by(id: order_id))
      @user = @order.user
      @order_notes = @order.order_histories.order(created_at: :desc).delivered
      mail to: @user.email, subject: "Order #{@order.number}: Delivered"
    end
  end

  def shipped(order_id)
    if(@order = Order.shipped.find_by(id: order_id))
      @user = @order.user
      @order_notes = @order.order_histories.order(created_at: :desc).shipped
      mail to: @user.email, subject: "Order #{@order.number}: Shipped"
    end
  end
end
