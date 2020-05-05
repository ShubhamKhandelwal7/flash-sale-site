class HomeController < ApplicationController
  skip_before_action :authorize

  def index
    @live_deals = Deal.live_deals(Time.current).with_attached_images
    if @live_deals.blank?
      @past_deals = Deal.past_live(ENV["PAST_LIVE_DEALS_SHOW"].to_i)
    end
  end

  def deals
    deal = Deal.live_deals(Time.current).with_attached_images
    if deal.blank?
      deal = Deal.past_live(ENV["PAST_LIVE_DEALS_SHOW"].to_i)
    end
    respond_to do |format|
      format.html { render partial: "deals", locals: { deals: deal }  }
    end
  end
end
