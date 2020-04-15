$(document).on("turbolinks:load", function(){
  function dealFormFields() {
    $('form').on('click', '.add_fields', function(event) {
      $(this).before($(this).data('fields'))
      event.preventDefault()
    })
  }
  dealFormFields()
});
