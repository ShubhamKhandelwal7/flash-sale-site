module Api
  class DealsController < ApiBaseController
    def live
      @live_deals = Deal.live_deals(Time.current)
      respond_to do |format|
        format.json
        format.html { render plain: 'invalid url' }
      end
    end

    def past
      @past_deals = Deal.past_deals(Time.current)
      respond_to do |format|
        format.json
        format.html { render plain: 'invalid url' }
      end
    end
  end
end
