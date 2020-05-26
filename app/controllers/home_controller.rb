class HomeController < ApplicationController
  skip_before_action :authorize

  def index
    @live_deals = Deal.live_deals(Time.current).with_attached_images
    @past_deals = Deal.past_live(ENV["PAST_LIVE_DEALS_SHOW"].to_i)

    respond_to do |format|
      format.html
      format.json { render json: { live_deals: Deal.live_deals(Time.current).pluck(:id, :updated_at).to_json  }}
    end
  end
end
