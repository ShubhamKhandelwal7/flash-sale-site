class dealPublishManager {
  constructor(defaultSelector) {
    this.$form = $(defaultSelector.formSelector);
    this.publishForm = defaultSelector.publishFormSelector;
    this.$publishDate = $(defaultSelector.publishDateSelector);
    this.$publishDataDiv = $(defaultSelector.publishDataDivSelector);
    this.$publishBtn = $(defaultSelector.publishBtnSelector);
    this.$republishBtn = $(defaultSelector.republishBtnSelector);
    this.unpublishBtn = defaultSelector.unpublishBtnSelector;
  }

  init() {
    this.$republishBtn.hide();
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
    this.$publishDataDiv.html($('<strong>').text(publishResp));
    this.$publishDataDiv.prop("class", "alert alert-success text-center");
    this.$publishDate.html(publishResp);
    this.$publishBtn.hide();
    this.$republishBtn.show();

    if($(this.unpublishBtn).length == 0) {
      let unpublishPath = this.$publishBtn.data('unpublish-url');
      this.$publishBtn.closest('div').append($('<div>').append($("<a>").attr({ href: unpublishPath, title: "Remove Schedule", id: "unschedule-deal", "data-confirm": "Are you sure ?" })
                                                       .addClass('btn btn-danger text-center').text('Remove Schedule').css('margin-top', '15px')));

    };
  };

  publishFailure() {
    this.$publishDataDiv.html($('<strong>').text("NOT Scheduled"));
    this.$publishDataDiv.attr("class", "alert alert-warning text-center");
  };

  ajaxError() {
    this.$publishDataDiv.html($('<strong>').text("Request Failed"));
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
    republishBtnSelector: "#republish-btn",
    unpublishBtnSelector: "#unschedule-deal"
  };
    let dealPublishObj = new dealPublishManager(defaultSelector);
    dealPublishObj.init();
  });
