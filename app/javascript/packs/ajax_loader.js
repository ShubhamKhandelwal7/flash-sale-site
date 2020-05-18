class AjaxLoader {
  constructor(defaultSelector) {
    this.$document = $(document);
    this.$spinner = $(defaultSelector.spinnerSelector);
  }

  init() {
    this.$spinner.hide()
    this.$document.on('ajax:beforeSend', (event) => {
      this.$spinner.show();
    }).on('ajax:complete', (event) => {
      this.$spinner.hide();
    });
  };
}

$(document).on("turbolinks:load", function(){
  let defaultSelector = {
    spinnerSelector: "#spinner-div"
  };
    let ajaxLoaderObj = new AjaxLoader(defaultSelector);
    ajaxLoaderObj.init();
  });