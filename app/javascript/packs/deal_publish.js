class dealPublishManager {
  constructor(defaultSelector) {
    this.$form = $(defaultSelector.formSelector);
    this.publishForm = defaultSelector.publishFormSelector;
    this.$publishDate = $(defaultSelector.publishDateSelector);
    this.$publishDataDiv = $(defaultSelector.publishDataDivSelector);
    this.$publishBtn = $(defaultSelector.publishBtnSelector);
    this.unpublishBtn = defaultSelector.unpublishBtnSelector;
  }

  init() {
    $(this.publishForm).on('ajax:success', (event) => {
      let response = event.detail[0];
      if(response.status == true) {
        this.publishSuccess(response.publish_presenter);
      } else {
        this.publishFailure();
      }
      event.preventDefault();
    }).on('ajax:error', (event) => {
      this.ajaxError();
    });
  }

  publishSuccess(publishResp) {
    // FIXME_AB: $('<strong>').text('fda'), then append
    this.$publishDataDiv.html("<strong>"+publishResp+"</strong>");
    this.$publishDataDiv.prop("class", "alert alert-success text-center");
    this.$publishDate.html(publishResp);
    this.$publishBtn.prop("value", "Re Schedule");

    if($(this.unpublishBtn).length == 0) {
      let unpublishPath = this.$publishBtn.data('unpublish-url');
      // FIXME_AB: make use of proper jquery
      let unpublishLink = "<a title=\"Remove Schedule\" class= \"btn btn-danger text-center\" id=\"unschedule-deal\" data-confirm= \"Are you sure ?\" href=" +
          unpublishPath + ">Remove Schedule</a>";

        // FIXME_AB: don't use br. use css class
      this.$publishBtn.closest('div').append( "<br><br>" + unpublishLink );
    };
  };

  publishFailure() {
    this.$publishDataDiv.html("<strong>NOT Scheduled</strong>");
    this.$publishDataDiv.attr("class", "alert alert-warning text-center");
  };

  ajaxError() {
    this.$publishDataDiv.html("<strong>Request Failed</strong>");
    this.$publishDataDiv.attr("class", "alert alert-error text-center");
  };
}

$(document).on("turbolinks:load", function(){
  let defaultSelector = {
    formSelector: "form",
    publishFormSelector: "#publish-form",
    publishDateSelector: "#publish-date",
    publishDataDivSelector: "#publish-data",
    publishBtnSelector: "#publish-btn",
    unpublishBtnSelector: "#unschedule-deal"
  };
    let dealPublishObj = new dealPublishManager(defaultSelector);
    dealPublishObj.init();
  });
