class AddressesController < ApplicationController

  def new
  end

  def create
    #FIXME_AB: current_user.addresses.build
    @address = current_user.addresses.build(address_params)
    if @address.default?
      @address.set_default
    end
    if @address.save
      if current_order.present?
        current_order.address = @address
        current_order.save
        redirect_to checkout_orders_path
      else
        redirect_to home_path, notice: "Address saved successfully"
      end
      #FIXME_AB: associate with current_order if exists
    else
      if current_order.present?
        render "orders/buy_now"
      else
        render :new
      end
    end
  end

  private def address_params
    params.require(:address).permit(:home_address, :state, :city, :pincode, :country, :user_id, :default)
  end

end
