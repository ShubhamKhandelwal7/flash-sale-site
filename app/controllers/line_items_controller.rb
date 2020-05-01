class LineItemsController < ApplicationController
  before_action :set_line_item

  def destroy
    # i18n
    if @line_item.destroy
      flash[:notice] = "Deal destroyed"
    else
      flash[:alert] = "Deal could not be destroyed"
    end
    redirect_to home_path
  end

  private def set_line_item
    @line_item = LineItem.find(params[:id])
    if @line_item.blank?
      redirect_to home_path, alert: "Line-item does not exists"
    end
  end
end