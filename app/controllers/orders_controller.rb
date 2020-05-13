class OrdersController < ApplicationController
  before_action :create_order, only: :add_to_cart, if: -> { current_order.blank? }

  def add_to_cart
    if current_order.add_items(params[:id])
      @line_item = LineItem.new(deal_id: params[:id], order_id: current_order.id)
      @line_item.evaluate_amounts
      if @line_item.save
        flash.now[:notice] = t(".success")
      else
        flash.now[:notice] = t(".failure")
      end
    end
  end

  def buy_now
  end

  def checkout
    if current_order.place_order
      session[:order_id] = nil
      # or redirect_to home_path, notice: "Thank you for placing the order !!!"
    else
      redirect_to home_path, notice: "Your Order could not get placed, please try again"
    end
  end

  def select_address
    address = Address.find(params[:id])
    unless address.default?
      address.set_default
    end
    if address.save
      redirect_to checkout_order_path
    else
      redirect_to buy_now_order_path(current_order), notice: "This address is incorrect, please choose another"
    end
  rescue ActiveRecord::RecordNotFound
  end

  def create_order
    #FIXME_AB: current_user.orders.build
    new_order = current_user.orders.build
    if new_order.save
      session[:order_id] = new_order.id
    end
  end
end
