module Api
  #FIXME_AB: class DealsController < Api::ApiBaseController
  class DealsController < ApiBaseController
    # skip_before_action :authorize_by_api_token
    # add_flash_types :error

#FIXME_AB: show like this use jbuilder
# [
#   {
#     "deals": [
#       {
#         "title": "Morbi mollis tellus ac",
#         "description": "Aenean vulputate eleifend tellus. Pellentesque dapibus hendrerit tortor. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Aliquam erat volutpat. Vivamus in erat ut urna cursus vestibulum.",
#         "price": "12.0",
#         "discount_price": "2.0",
#         "published_at": "2020-05-28T14:08:33.200+05:30",
#         "tax": "2.0",
#       },
#       {
#         "title": "Morbi mollis tellus ac",
#         "description": "Aenean vulputate eleifend tellus. Pellentesque dapibus hendrerit tortor. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Aliquam erat volutpat. Vivamus in erat ut urna cursus vestibulum.",
#         "price": "12.0",
#         "discount_price": "2.0",
#         "published_at": "2020-05-28T14:08:33.200+05:30",
#         "tax": "2.0",
#       },

#     ]
#   }
# ]
    def live
      @live_deals = Deal.live_deals(Time.current)
      respond_to do |format|
        format.json 
        format.html { render plain: 'invalid url' }
        # format.html{redirect_to home_path, error: "Could not find page you were looking for"}
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
