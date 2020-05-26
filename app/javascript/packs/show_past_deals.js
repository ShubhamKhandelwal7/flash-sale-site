class PastDealsPresenter {
  constructor(defaultSelector) {
    this.$pastDealsDiv = $(defaultSelector.pastDealsDivSelector);
    this.$pastDealsBtn = $(defaultSelector.pastDealsBtnSelector);
  }

  init() {
    this.$pastDealsBtn.on('ajax:success', (event) => {
      this.showPastDeals();
    });
    this.$pastDealsBtn.on('ajax:error', (event) => {
      this.requestFailure();
    });
  };

  showPastDeals() {
    this.$pastDealsBtn.hide();
    this.$pastDealsDiv.addClass('mt-2').html($('<h3>').text("PAST DEALS").addClass('text-center mt-2 mb-4'));
    this.$pastDealsDiv.append(this.$pastDealsBtn.data('past-deals'));
  };

  requestFailure() {
    htmlResp = "Request could not get completed, please try again";
    this.$pastDealsDiv.addClass('text-center mt-2').html($('<strong>').text(htmlResp));
  };
}

$(document).on("turbolinks:load", function(){
  let defaultSelector = {
    pastDealsBtnSelector: "#past-deals-btn",
    pastDealsDivSelector: "#past-deals-div"
  };
    let pastDealsObj = new PastDealsPresenter(defaultSelector);
    pastDealsObj.init();
  });