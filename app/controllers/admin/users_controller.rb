module Admin
  class UsersController < AdminController
    
    def top_customers
      @from_date = Date.parse(params[:from_date].present? ? params[:from_date] : (Date.today - REPORTS[:top_customer_lookback].days).to_s)
      @to_date = Date.parse(params[:to_date].present? ? params[:to_date] : (Date.today).to_s)

      orders = Order.placed_orders.where(created_at: @from_date..@to_date).group("user_id")
      @users_total_amount = orders.order("sum_total_amount desc").sum("total_amount")
      @users_orders_count = orders.count
    end

  end
end

