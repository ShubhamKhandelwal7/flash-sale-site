module Admin
  class OrdersController < AdminController
    before_action :set_order, only: [:update_state, :edit]

    #FIXME_AB: before actoin to check if email present and user not present, redirect.
    def index

      # if @user
      #   ...
      # else
      #   ....
      # end

      if params[:user_email].present? && (user = User.find_by(email: params[:user_email]))
        @orders = user.orders.paid_orders
        flash.now[:notice] = "Orders of #{user.email} found"
      elsif params[:user_email].present?
        flash.now[:alert] = "No user found with email: #{params[:user_email]}"
      else
        @orders = Order.includes(:user).paid_orders
      end
      @orders = @orders.order(placed_at: :desc).order(created_at: :desc)
      #FIXME_AB: pagination
    end

    def edit
    end

    #FIXME_AB: separate actions. shipped, delivered, cancel
    def update_state
      if params[:delivered] == '1'&& @current_order.mark_as_delivered! #state = Order.states[:delivered]
        redirect_to admin_orders_path, notice: "State of Order:#{@current_order.number} updated successfully"
      elsif params[:cancelled] == '1' && @current_order.mark_as_cancelled! #.state = Order.states[:cancelled]
        redirect_to admin_orders_path, notice: "State of Order:#{@current_order.number} updated successfully"
      else
        render :edit
      end
    end

    private def set_order
      @current_order = Order.find_by(id: params[:id])
      if @current_order.blank?
        redirect_to admin_orders_path, alert: "Order could not get retrieved"
      end
    end
  end
end
