class OrderAddressManager {
  constructor(defaultSelector) {
    this.$form = $(defaultSelector.formSelector);
    this.addFieldsClass = defaultSelector.addFieldSelector;
  }

  init() {
    this.$form.on('click', this.addFieldsClass, (event) => {
      this.orderFormFields();
      event.preventDefault();
    });
  }

  orderFormFields() {
    let $fieldsObj = $(this.addFieldsClass)
    $fieldsObj.before($fieldsObj.data('fields'));
    $fieldsObj.hide();
  };
}

$(document).on("turbolinks:load", function(){
  let defaultSelector = {
    formSelector: "form",
    addFieldSelector: ".add_fields"
  };
    let addressMgrObj = new OrderAddressManager(defaultSelector);
    addressMgrObj.init();
  });