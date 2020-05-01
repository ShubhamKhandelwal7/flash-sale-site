class OrdersController < ApplicationController
  before_action :create_order, only: :add_to_cart, if: -> { current_order.blank? }

  def add_to_cart
    present_order = current_order || @order
    @line_item = LineItem.new(deal_id: params[:id], order_id: present_order.id)
    @line_item.evaluate_discounts
    if @line_item.save
      # yet to be internationalized
      flash.now[:notice] = "Deal added to Cart" 
    else
      flash.now[:notice] = "Same Deal cannot be added multiple times" 
    end
  end

  def create_order
    @order = Order.create(user_id: current_user.id,
      address_id: current_user.addresses.first.id)
    session[:order_id] = @order.id
  end
end
