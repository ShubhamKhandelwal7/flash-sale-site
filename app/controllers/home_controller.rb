class HomeController < ApplicationController
  skip_before_action :authorize

  def index
    @live_deals = Deal.live_deals(Time.current).with_attached_images
    @past_deals = Deal.with_attached_images.past_live(ENV["PAST_LIVE_DEALS_SHOW"].to_i)
    live_deals_poll = Deal.live_deals(Time.current).present? ? Deal.live_deals(Time.current).pluck(:id, :live_end).to_json : nil

    respond_to do |format|
      format.html
      format.json { render json: { live_deals: live_deals_poll }}
    end
  end
end
