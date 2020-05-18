class OrdersController < ApplicationController
  #FIXME_AB: create_order from ensure_current_order
  # before_action :create_order, only: :add_to_cart, if: -> { current_order.blank? }
  before_action :ensure_current_order, :ensure_order_in_cart_state

  def add_to_cart
    #FIXME_AB:  if current_order.add_item(params[:id])
    if current_order.add_item(params[:id])
      flash.now[:notice] = t(".success")
    else
      flash.now[:notice] = t(".failure")
    end
  end

  #FIXME_AB: before_action :ensure_order_is_in_cart_state, should also be called in all checkout actions
  def rem_from_cart
    if current_order.remove_item(params[:id])
    #FIXME_AB: current_order.remove_item(deal_id) => true /false
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
    address = current_user.addresses.find(params[:id])
    #FIXME_AB: since we'll have call back
    # if params[:default] == '1'
    #   address.default = true
    # end
    if (params[:default] == '1')
      address.default = true
    end

    if address.save && current_order.set_address!(address)
      #FIXME_AB: this would also change
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

  #FIXME_AB: if current_order is not present create one
  private def ensure_current_order
    if !current_order.present?
      create_order
      redirect_to home_path, notice: "Please goto 'my orders' to view your orders"
    end
  end

  private def ensure_order_in_cart_state
    if !current_order.cart?
      redirect_to home_path, notice: "Please goto 'my orders' to view your orders"
    end
  end
end
