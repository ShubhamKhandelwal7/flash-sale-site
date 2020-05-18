$(document).on("turbolinks:load", function(){
  function dealFormFields() {
    $('form#deals-form').on('click', '.add_fields', function(event) {
      _this = $(this);
      _this.before(_this.data('fields'));
      event.preventDefault();
    })
  }
  dealFormFields();
});
