class LineItemsController < ApplicationController
  before_action :set_line_item

  #FIXME_AB: move to orders controller
  #FIXME_AB: before removing line item check that line item belongs to current user's order
  #FIXME_AB: before removing item check that order should be in cart state

  private def set_line_item
    @line_item = LineItem.find(params[:id])
    if @line_item.blank?
      redirect_to home_path, alert: "Line-item does not exists"
    end
  end
end
