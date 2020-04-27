class HomeController < ApplicationController
  skip_before_action :authorize

  def index
    @live_deals = Deal.live_deals(Time.current).with_attached_images
    if @live_deals.blank?
      @past_deals = Deal.past_live(ENV["PAST_LIVE_DEALS_SHOW"].to_i)
    end
  end
end
