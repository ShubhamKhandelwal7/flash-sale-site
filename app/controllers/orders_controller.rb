class OrdersController < ApplicationController
  before_action :ensure_current_order, :ensure_order_in_cart_state, except: :index
  before_action :ensure_payment_success, only: :checkout
  before_action :ensure_stripe_token_present, only: :charge

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

  def payment
    logger.tagged("Order: payments") { logger.info { "initiating payment for order id: #{current_order.id}" } }
    @current_order = current_order
    #FIXME_AB: add logging: initiating payment for order id : xxxx
    #FIXME_AB: do this tagged logging 'order payments'
  end

  def charge
    #FIXME_AB: tagged logging
    #FIXME_AB: add a before action to check that stripe token should be present. redirect with message
    #FIXME_AB: this all should be in one db transaction
    logger.tagged("Order: payments") do
      logger.info { "Fetched user payment method info(stripeToken) against order id: #{current_order.id}" }
      current_order.transaction do
        if current_order.make_payment(params[:stripeToken])
          logger.info { "Payment process success against order id: #{current_order.id}, redirecting to checkout" }
          redirect_to checkout_orders_path
        elsif current_order.payments.success.present?
          logger.info { "Already a Payment present with success state against order id: #{current_order.id}, redirecting to checkout" }
          redirect_to checkout_orders_path, notice: "A successfull payment already exists against this order"
        elsif current_order.payments.no_success.count <= ENV['MAX_PAYMENT_ATTEMPTS'].to_i
          logger.info { "Payment failed with #{current_order.payments.no_success.count} failed attemts for order id: #{current_order.id},
            trying again and redirecting to buy_now" }
          redirect_to buy_now_orders_path, alert: "Payment failed for some reason, please try again."
        else
          logger.info { "Payment failed with #{current_order.payments.no_success.count} failed attemts for order id: #{current_order.id},
            max failed attempts reached so redirecting to home_path" }
          redirect_to home_path, notice: "Your Order could not get placed, payment failed"
        end
      end
    end
  end

  def checkout
    if current_order.place_order
      #FIXME_AB: prefer OrderMailer so that we can have all order related emails at one place
      session[:order_id] = nil
    else
      redirect_to home_path, notice: "Your Order could not get placed, please try again"
    end
  end

  def select_address
    address = current_user.addresses.find(params[:id])

    if (params[:default] == '1')
      address.default = true
    end

    if address.save && current_order.set_address!(address)
      redirect_to payment_orders_path
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
    end
  end

  private def ensure_order_in_cart_state
    if !current_order.cart?
      session[:order_id] = nil
      redirect_to home_path, notice: "Please goto 'my orders' to view your orders"
    end
  end

  private def ensure_payment_success
    if current_order.payments.success.blank?
      redirect_to payment_orders_path, notice: "Please make the payment against your current order"
    end
  end

  private def ensure_stripe_token_present
    if params[:stripeToken].blank?
      logger.tagged("Order: payments") { logger.info { "Stripe token blank for order id: #{current_order.id}, redirecting to payment_orders_path" } }
      redirect_to payment_orders_path, notice: "Payment could not get processed, please try again"
    end
  end
end
