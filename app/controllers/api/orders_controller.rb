module Api
  class OrdersController < ApplicationController
    skip_before_action :authorize 

    def index
      if params[:token] && (user = User.find_by(authentication_token: params[:token]))
        orders = user.orders.present? ? user.orders.to_json : nil
      end

      respond_to do |format|
        format.json { render json: orders }
      end
    end
  end
end
