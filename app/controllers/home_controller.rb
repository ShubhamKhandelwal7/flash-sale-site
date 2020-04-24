class HomeController < ApplicationController
  # skip_before_action :authorize

  #FIXME_AB: home page should be accessible to non logged in users too. Just that, they can not add to cart or buy
  def index
    #FIXME_AB: since live_deals is a scope it will return an object of AREL and never be a nil object so .& is not the right way. You should do  Deal.live_deals.with_attached_images
    #FIXME_AB: Also I sould suggest to have this written as Deal.live_deals(Date.today).with_attached_images. So that scope can be reused
    @live_deals = Deal.live_deals&.with_attached_images
    if @live_deals.blank?
      #FIXME_AB: should be another scope Deal.past_live(2)
      @past_deals = Deal.order(:published_at).last(2)
    end
  end
end
