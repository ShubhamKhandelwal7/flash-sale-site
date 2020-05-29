module Admin
  class OrdersController < AdminController

    def index
      if params[:user_email].present? && (user = User.find_by(email: params[:user_email]))
        @orders = user.orders.paid_orders.order(:created_at)
        flash.now[:notice] = "Orders of #{user.email} found"
      elsif params[:user_email].present?
        flash.now[:alert] = "No user found with email: #{params[:user_email]}"
      else
        @orders = Order.includes(:user).paid_orders.order(:created_at)
      end
    end
  end
end