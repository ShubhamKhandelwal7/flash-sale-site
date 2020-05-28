module Api
  class DealsController < ApplicationController
    skip_before_action :authorize 

    def live
      live_deals = Deal.live_deals(Time.current).present? ? Deal.live_deals(Time.current).to_json : nil
      respond_to do |format|
        format.json { render json: live_deals }
      end
    end

    def past
      past_deals = Deal.past_deals(Time.current).present? ? Deal.past_deals(Time.current).to_json : nil
      respond_to do |format|
        format.json { render json: past_deals }
      end
    end
  end
end
