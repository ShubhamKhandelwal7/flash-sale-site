class HomeController < ApplicationController
  skip_before_action :authorize

  def index
    @live_deals = Deal.live_deals(Time.current).with_attached_images
    @past_deals = Deal.with_attached_images.past_live(ENV["PAST_LIVE_DEALS_SHOW"].to_i)
    #FIXME_AB: optimize by making a seperate action
  end

  def poll
    live_deals = Deal.live_deals(Time.current)
    live_deals = live_deals.present? ? live_deals.pluck(:id, :live_end).to_json : nil

    render json: { live_deals: live_deals }
  end
end
