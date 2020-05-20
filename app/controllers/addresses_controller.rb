class AddressesController < ApplicationController

  def new
  end

  def create
    if ( @address = current_user.addresses.create(address_params) ) && @address.persisted?
      if current_order&.set_address!(@address)
        redirect_to payment_orders_path
      else
        redirect_to home_path, notice: t("addresses.create.success")
      end
    else
      if current_order.present?
        render "orders/buy_now"
      else
        render :new
      end
    end
  end

  private def address_params
    #FIXME_AB: lets not permit_user id.
    params.require(:address).permit(:home_address, :state, :city, :pincode, :country, :default)
  end

end
