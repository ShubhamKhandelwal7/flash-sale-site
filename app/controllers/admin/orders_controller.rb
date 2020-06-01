module Admin
  class OrdersController < AdminController
    before_action :set_order, only: [:shipped, :delivered, :cancel, :show]
    before_action :check_user, only: :index

    def index
      if @user
        @orders = @user.orders.paid_orders
        flash.now[:notice] = "Orders of #{@user.email} found"
      else
        @orders = Order.includes(:user).paid_orders
      end
      #FIXME_AB: add PER_PAGE_ORDER in application.yml.example and in requried keys
      @orders = @orders.order(placed_at: :desc, created_at: :desc).page(params[:page]).per(ENV['PER_PAGE_ORDER'].to_i)
    end

    def show
    end

    def shipped
      if @current_order.mark_as_shipped!(params[:note])
        flash[:notice] =  "State of Order:#{@current_order.number} updated successfully"
      else
        flash[:alert] = "State of Order:#{@current_order.number} could not get updated"
      end
      #FIXME_AB: don't redirect user to list, keep on the same page
      redirect_to admin_orders_path
    end

    def delivered
      if @current_order.mark_as_delivered!(params[:note])
        flash[:notice] =  "State of Order:#{@current_order.number} updated successfully"
      else
        flash[:alert] = "State of Order:#{@current_order.number} could not get updated"
      end
      #FIXME_AB: don't redirect user to list, keep on the same page
      redirect_to admin_orders_path
    end

    def cancel
      if @current_order.mark_as_cancelled!(params[:note])
        flash[:notice] =  "State of Order:#{@current_order.number} updated successfully"
      else
        flash[:alert] = "State of Order:#{@current_order.number} could not get updated"
      end
      #FIXME_AB: don't redirect user to list, keep on the same page
      redirect_to admin_orders_path
    end

    #FIXME_AB: separate actions. shipped, delivered, cancel
    #FIXME_AB: I think we can delete this action
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

    private def check_user
      if params[:user_email].present? && !(@user = User.find_by(email: params[:user_email]))
        redirect_to admin_orders_path, notice: "No user found with email: #{params[:user_email]}"
      end
    end
  end
end
