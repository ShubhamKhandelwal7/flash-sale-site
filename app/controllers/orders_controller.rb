class OrdersController < ApplicationController
  before_action :create_order, only: :add_to_cart, if: -> { current_order.blank? }
  before_action :ensure_current_order, except: [:create_order, :add_to_cart]

  def add_to_cart
    added_item = current_order.add_item(params[:id])
      #FIXME_AB: line_items create should be the part of add_items
      # @line_item = LineItem.new(deal_id: params[:id], order_id: current_order.id)
      # @line_item.evaluate_amounts
    if added_item&.save
      flash.now[:notice] = t(".success")
    else
      flash.now[:notice] = t(".failure")
    end
  end

  def rem_from_cart
    remove_item = current_order.line_items.find_by(id: params[:id])
    if current_order.state == 'cart' && remove_item&.destroy
      flash[:notice] = "Deal destroyed"
    else
      flash[:alert] = "Deal could not be destroyed"
    end
    redirect_to home_path
  end

  def buy_now
    unless current_order.update_totals && current_order.save
      redirect_to home_path, notice: "Could not proceed further, please try again"
    end
  end

  def checkout
    if current_order.place_order
      session[:order_id] = nil
    else
      redirect_to home_path, notice: "Your Order could not get placed, please try again"
    end
  end

  def select_address
    #FIXME_AB: address should be associated with current_order
    #FIXME_AB: current_user.addresses.find
    address = current_user.addresses.find(params[:id])
    #FIXME_AB: also handle the case when address not found
    if (params[:default] == '1') && !address.default?
      address.set_default
    end
    if address.save
      current_order.address = address
      current_order.save
      redirect_to checkout_orders_path
    else
      redirect_to buy_now_orders_path, notice: "The address is invalid, please choose another"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to buy_now_orders_path, notice: "Address could not be found"
  end

  private def create_order
    new_order = current_user.orders.build
    if new_order.save
      session[:order_id] = new_order.id
    end
  end

  private def ensure_current_order
    unless current_order.present?
      redirect_to home_path, notice: "Please goto 'my orders' to view your orders"
    end
  end
end
