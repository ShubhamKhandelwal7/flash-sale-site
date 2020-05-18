class OrdersController < ApplicationController
  before_action :ensure_current_order, :ensure_order_in_cart_state, except: :index

  def index
    @orders = current_user.orders.placed_orders
  end

  def add_to_cart
    if current_order.add_item(params[:id])
      flash.now[:notice] = t(".success")
    else
      flash.now[:notice] = t(".failure")
    end
  end

  def rem_from_cart
    if current_order.remove_item(params[:id])
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
      #FIXME_AB: prefer OrderMailer so that we can have all order related emails at one place
      UserMailer.order_placed(current_order.id).deliver_later
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
    if !current_order.present?
      create_order
      #FIXME_AB: remove redirect so that add to cart works
      redirect_to home_path, notice: "Please goto 'my orders' to view your orders"
    end
  end

  private def ensure_order_in_cart_state
    if !current_order.cart?
      redirect_to home_path, notice: "Please goto 'my orders' to view your orders"
    end
  end
end
