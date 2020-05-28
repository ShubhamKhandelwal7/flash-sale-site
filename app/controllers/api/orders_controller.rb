module Api
  class OrdersController < ApplicationController
    skip_before_action :authorize
    #FIXME_AB: before_action: authorize_by_api_token
    #FIXME_AB: api base controller define a method authorize_by_api_token => error=> status code 422
    def index
      if params[:token] && (user = User.find_by(authentication_token: params[:token]))
        #FIXME_AB: jbuilder
        #FIXME_AB: only placed orders with address info, payment infos
        orders = user.orders.present? ? user.orders.to_json : nil
      end

      respond_to do |format|
        format.json { render json: orders }
      end
    end
  end
end
