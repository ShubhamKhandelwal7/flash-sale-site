class AjaxLoader {
  constructor(defaultSelector) {
    this.$document = $(document);
    this.$spinner = $(defaultSelector.spinnerSelector);
    this.$addToCartBtn = $(defaultSelector.addToCartBtnSelector);
  }

  init() {
    this.$addToCartBtn.on('click', (event) => {
      $('html').animate({scrollTop:0}, 'slow');
    });
    this.$spinner.hide();
    $.LoadingOverlay("show");
    this.$document.on('ajax:beforeSend', (event) => {
      // this.$spinner.show();
      $.LoadingOverlay("show");
    }).on('ajax:complete', (event) => {
      // this.$spinner.hide();
      $.LoadingOverlay("hide");
    });
  };
}

$(document).on("turbolinks:load", function(){
  let defaultSelector = {
    spinnerSelector: "#spinner-div",
    addToCartBtnSelector: ".add-to-cart-btn"
  };
    let ajaxLoaderObj = new AjaxLoader(defaultSelector);
    ajaxLoaderObj.init();
  });