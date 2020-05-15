class AddressesController < ApplicationController

  def new
  end

  def create
    @address = current_user.addresses.build(address_params)

    #FIXME_AB: we can get rid of this if we use callback. comment added in address model
    if @address.default?
      @address.set_default
    end

    #FIXME_AB: if (@address = current_user.addresses.create(address_params) )
    if @address.save
      #FIXME_AB:  if current_order&.set_address!(@address)
      if current_order.present?
        current_order.address = @address
        current_order.save
        redirect_to checkout_orders_path
      else
        #FIXME_AB: lets use I18n
        redirect_to home_path, notice: "Address saved successfully"
      end
    else
      if current_order.present?
        render "orders/buy_now"
      else
        render :new
      end
    end
  end

  # def create
  #   if (@address = current_user.addresses.create(address_params) )
  #     if current_order&.set_address!(@address)
  #       redirect_to checkout_orders_path
  #     else
  #       redirect_to home_path, notice: "Address saved successfully"
  #     end
  #   else
  #     if current_order.present?
  #       render "orders/buy_now"
  #     else
  #       render :new
  #     end
  #   end
  # end


  private def address_params
    params.require(:address).permit(:home_address, :state, :city, :pincode, :country, :user_id, :default)
  end

end
