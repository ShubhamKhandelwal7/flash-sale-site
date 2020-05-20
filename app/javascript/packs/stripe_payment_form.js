$(document).on("turbolinks:load", function(){
  var form = document.getElementById('payment-form');
  let stripe_key = form.getAttribute("data-stripe-key");
  var stripe = Stripe(stripe_key);

  var elements = stripe.elements();

  var style = {
    base: {
      color: '#32325d',
      fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '16px',
      '::placeholder': {
        color: '#aab7c4'
      }
    },
    invalid: {
      color: '#fa755a',
      iconColor: '#fa755a'
    }
  };

  // FIXME_AB: here you can have optoin to remove zip from the form
  var card = elements.create('card', {iconStyle: 'solid'});
  card.mount('#card-element');

  card.on('change', function(event) {
    var displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  form.addEventListener('submit', function(event) {
    event.preventDefault();

    stripe.createToken(card).then(function(result) {
      if (result.error) {
        var errorElement = document.getElementById('card-errors');
        errorElement.textContent = result.error.message;
      } else {
        stripeTokenHandler(result.token);
      }
    });
  });

  function stripeTokenHandler(token) {
    var form = document.getElementById('payment-form');
    var hiddenInput = document.createElement('input');
    hiddenInput.setAttribute('type', 'hidden');
    hiddenInput.setAttribute('name', 'stripeToken');
    hiddenInput.setAttribute('value', token.id);
    form.appendChild(hiddenInput);

    form.submit();
  }
});
