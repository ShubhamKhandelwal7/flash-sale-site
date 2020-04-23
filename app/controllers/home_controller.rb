class HomeController < ApplicationController
  # skip_before_action :authorize

  def index
    @live_deals = Deal.live_deals&.with_attached_images
    if @live_deals.blank?
      @past_deals = Deal.order(:published_at).last(2)
    end
  end
end