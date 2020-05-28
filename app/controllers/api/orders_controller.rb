module Api
  class OrdersController < ApiBaseController
    before_action :authorize_by_api_token
    # skip_before_action :authorize
    #FIXME_AB: before_action: authorize_by_api_token
    #FIXME_AB: api base controller define a method authorize_by_api_token => error=> status code 422
    def index
        #FIXME_AB: jbuilder
        #FIXME_AB: only placed orders with address info, payment infos
        @orders = current_user.orders.placed_orders
        respond_to do |format|
          format.json
          format.html { render plain: 'Invalid URL', status: 422 }
        end
    end
  end
end
