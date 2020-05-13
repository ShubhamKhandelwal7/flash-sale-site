class AddressesController < ApplicationController

  def new
  end

  def create
    #FIXME_AB: current_user.addresses.build
    @address = Address.new(address_params)
    @address.user_id = current_user.id
    @address.set_default
    respond_to do |format|
      if @address.save
        #FIXME_AB: associate with current_order if exists
        format.html { redirect_to checkout_order_path(current_order) }
      else
        format.html { render "orders/buy_now" }
      end
    end
  end

  private def address_params
    params.require(:address).permit(:home_address, :state, :city, :pincode, :country, :user_id)
  end

end
