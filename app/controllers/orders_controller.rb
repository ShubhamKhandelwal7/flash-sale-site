class OrdersController < ApplicationController
  before_action :create_order, only: :add_to_cart, if: -> { current_order.blank? }

  def add_to_cart
    #FIXME_AB: if current_order.add_item(deal_id)
    if current_order.add_items(params[:id])
      @line_item = LineItem.new(deal_id: params[:id], order_id: current_order.id)
      @line_item.evaluate_amounts
      if @line_item.save
        # yet to be internationalized
        flash.now[:notice] = "Deal added to Cart"
      else
        flash.now[:notice] = "Same Deal cannot be added multiple times"
      end
    end
  end

  def create_order
    @order = Order.create(user_id: current_user.id)
    session[:order_id] = @order.id
  end
end
