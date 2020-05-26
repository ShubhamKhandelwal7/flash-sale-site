const PER_SECONDS_CHECK = 2*60*1000
const POLLING_INTERVAL = 60000

class HomepageUpdator {
  constructor(defaultSelector) {
    this.dealsIndexDiv = defaultSelector.dealsIndexDivSelector;
  }

  init() {
    this.$dealsIndexDiv = $(this.dealsIndexDiv);
    this.currentDeals = this.$dealsIndexDiv.data("deal_ids");
    setInterval(this.checkDeals.bind(this), POLLING_INTERVAL);
  };

  checkDeals() {
    $.ajax({
      url: this.$dealsIndexDiv.data("url"),
      type: "GET",
      dataType: 'json',

      success: (response) => {
        resp = JSON.parse(response.live_deals)
        this.checkResponse(resp, this.currentDeals);
      },
      error: (response) => {
        console.log("AJAX request failed");
      }
    });
  };

  checkResponse(response, currentDeals) {
    for(var latestDeal of response) {
      // FIXME_AB: update
      if((Date.parse(latestDeal[1]) >= (Date.now() - PER_SECONDS_CHECK)) || currentDeals.length != response.length || !currentDeals.includes(latestDeal[0])) {
        location.reload(true);
      };
    };
  };
}

$(document).on("turbolinks:load", function(){
  let defaultSelector = {
    dealsIndexDivSelector: "#deals-home"
  };
    let homeUpdatorObj = new HomepageUpdator(defaultSelector);
    homeUpdatorObj.init();
  });
