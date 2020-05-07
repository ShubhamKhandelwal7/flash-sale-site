$(document).on("turbolinks:load", function(){
  function dealRemoveImage() {
    $('form#deals-form').on('click', '.deal-img-rem', function(event) {
      _this = $(this)
      if(confirm("Are you sure?")) {
        $.ajax({
          url: _this.data("url"),
          type: "GET",

          success: function(response) {
            if(response.status) {
              _this.closest('div').hide();
            } else {
              _this.closest('div').append("<p>Not Found: Image not found</p>")
            }
          },
          error: function(response) {
            console.log("Couldnt remove image")
            _this.closest('div').append("<p>Internal Error: Image could not be removed</p>")
          }
        })
      }
      event.preventDefault()
    })
  }
  dealRemoveImage()
});
