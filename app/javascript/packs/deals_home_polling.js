{/* <div id="deal-loading">Deals loading...</div> */}

const checkDeals = () => {
  fetch("/homedeals")
  .then(response => response.text())
  .then(response => {
    document.getElementById("deals-home").innerHTML = response;
  });
};

setInterval(checkDeals, 10000);