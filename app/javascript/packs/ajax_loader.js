require("gasparesganga-jquery-loading-overlay")

class AjaxLoader {
  constructor(defaultSelector) {
    this.$document = $(document);
    this.$addToCartBtn = $(defaultSelector.addToCartBtnSelector);
  }

  init() {

    this.$addToCartBtn.on('click', (event) => {
      $('html').animate({scrollTop:0}, 'slow');
    });
    this.$document.on('ajax:beforeSend', (event) => {
      $.LoadingOverlay("show",{imageColor: 'maroon'});
    }).on('ajax:complete', (event) => {
      $.LoadingOverlay("hide");
    });
  };
}

$(document).on("turbolinks:load", function(){
  let defaultSelector = {
    addToCartBtnSelector: ".add-to-cart-btn"
  };
    let ajaxLoaderObj = new AjaxLoader(defaultSelector);
    ajaxLoaderObj.init();
  });
