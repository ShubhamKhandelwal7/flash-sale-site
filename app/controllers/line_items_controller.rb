class LineItemsController < ApplicationController
  before_action :set_line_item

  private def set_line_item
    @line_item = LineItem.find(params[:id])
    if @line_item.blank?
      redirect_to home_path, alert: "Line-item does not exists"
    end
  end
end
