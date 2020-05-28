module Api
  class OrdersController < ApiBaseController
    before_action :authorize_by_api_token

    def index
        @orders = current_user.orders.placed_orders
        respond_to do |format|
          format.json
          format.html { render plain: 'Invalid URL', status: 422 }
        end
    end
  end
end
