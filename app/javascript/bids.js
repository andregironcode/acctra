    var csrfToken = $("meta[name='csrf-token']").attr("content");
  
    $('.negotiateBtn').on('click', function() {
      var bidId = $(this).data('bid-id');
      $('#bidId').val(bidId);
      var product = $(`#${bidId}-bid-productName`).text();
      var basePrice= $(`#${bidId}-base-price`).text()
      var sellerOffer= $(`#${bidId}-bid-sellerOffer`).text()
      var quantity= $(`#${bidId}-bid-pcs`).text()
      $('#bid-product').html(` <span class="modal-text"> Product Name: </span> <span>  ${product} </span>`)
      $('#bid-basePrice').html(` <span class="modal-text"> Base Price: </span> <span>  ${basePrice} </span>`)
      if (sellerOffer !== ''){
        $('#bid-offeredPrice').html(` <span class="modal-text"> Seller's Offer: </span> <span>  ${sellerOffer} </span>`)
      }else{
        var buyerOffer= $(`#${bidId}-bid-buyerOffer`).text() 
        $('#bid-offeredPrice').html(` <span class="modal-text"> Buyer's Offer: </span> <span>  ${buyerOffer} </span>`)
      }
      $('#bid-pcs').html(` <span class="modal-text"> Quantity: </span> <span>  ${quantity} </span>`)
      
    });

    function accept(e) {
        e.preventDefault();
        var bidId = $(e.target).data('bid-id');
        var isSellerView = $(e.target).data('seller');
        var url = '/update-bid?status=accept'; 
        
        // Show loading indicator
        var originalText = $(e.target).text();
        $(e.target).text("Processing...").prop('disabled', true);
        
        $.ajax({
        url: url,
        type: 'POST',
        data: { bid_id: bidId },
        headers: {
          'X-CSRF-Token': csrfToken  
        },
        success: function(response) {
          window.location.href = response.redirect_url;
        },
        error: function(xhr, status, error) {
          // Reset the button
          $(e.target).text(originalText).prop('disabled', false);
          
          if (xhr.responseJSON && xhr.responseJSON.error) {
            // Check if it's a stock error
            if (xhr.responseJSON.error.includes("Not enough stock available")) {
              if (isSellerView) {
                toastr.error("Not enough stock available to fulfill this bid. Please update your inventory before accepting.");
              } else {
                toastr.error("Not enough stock available from the seller to fulfill this bid. Please wait for the seller to update their inventory.");
              }
            } else {
              toastr.error(xhr.responseJSON.error);
            }
          } else {
            toastr.error("Error processing the request. Please try again later.");
          }
        }
      });
    };
  
    function reject (e) {
      e.preventDefault();
      var bidId = $(e.target).data('bid-id');
      var url = '/update-bid?status=reject';
      
      // Show loading indicator
      var originalText = $(e.target).text();
      $(e.target).text("Processing...").prop('disabled', true);
  
      $.ajax({
        url: url,
        type: 'POST',
        data: { bid_id: bidId },
        headers: {
            'X-CSRF-Token': csrfToken  
          },
        success: function(response) {
            window.location.href = response.redirect_url;
        },
        error: function(xhr, status, error) {
          // Reset the button
          $(e.target).text(originalText).prop('disabled', false);
          
          if (xhr.responseJSON && xhr.responseJSON.error) {
            toastr.error(xhr.responseJSON.error);
          } else {
            toastr.error("Error processing the request. Please try again later.");
          }
        }
      });
    };
  
    function fivePercentRule() {
      var bidId = $('#bidId').val();
      var priceInput = $('#offerPrice');
      var enteredPriceText = priceInput.val();
      var enteredPrice = parseFloat(enteredPriceText.trim().replace(/[$,]/g, ''));
      var basePrice = parseFloat($(`#${bidId}-base-price`).text().trim().replace(/[$,]/g, ''));
      
      let minPrice = Math.round(basePrice * 0.95);
      
      // Find the error message element or create one if it doesn't exist
      var errorMessageEl = $('#bid-price-error');
      if (errorMessageEl.length === 0) {
        priceInput.after('<small id="bid-price-error" class="text-danger" style="display: none;">Bid price error</small>');
        errorMessageEl = $('#bid-price-error');
      }
      
      // Handle NaN values
      if (isNaN(enteredPrice)) {
        toastr.error('Please enter a valid number');
        priceInput.addClass('is-invalid');
        priceInput.data('valid', 'false');
        errorMessageEl.text('Please enter a valid number').show();
        return;
      }
      
      // Check if the price is within acceptable range
      if (enteredPrice < minPrice) {
          toastr.error(`The price cannot be less than 95% of the base price, which is $${minPrice}`);
          // Mark the field as invalid
          priceInput.addClass('is-invalid');
          priceInput.data('valid', 'false');
          errorMessageEl.text(`Bid price must be at least $${minPrice} (95% of base price)`).show();
      } else if (enteredPrice > basePrice) {
          toastr.error(`The price cannot exceed the base price of $${basePrice}. Please enter a lower price.`);
          // Mark the field as invalid
          priceInput.addClass('is-invalid');
          priceInput.data('valid', 'false');
          errorMessageEl.text(`Bid cannot exceed base price of $${basePrice}`).show();
      } else {
          // Price is valid
          priceInput.val(Math.round(enteredPrice));
          priceInput.removeClass('is-invalid');
          priceInput.data('valid', 'true');
          errorMessageEl.hide();
      }
    }

    $('#negotiateForm').on('submit', function(e) {
      e.preventDefault();  
      var bidId = $('#bidId').val();
      var priceInput = $('#offerPrice');
      var price = priceInput.val();
      var buyer = $('#buyer_id').val();
      
      // Get the base price for validation
      var basePrice = parseFloat($(`#${bidId}-base-price`).text().trim().replace(/[$,]/g, ''));
      var minPrice = Math.round(basePrice * 0.95);
      var enteredPrice = parseFloat(price);
      
      // Find error message element
      var errorMessageEl = $('#bid-price-error');
      if (errorMessageEl.length === 0) {
        priceInput.after('<small id="bid-price-error" class="text-danger" style="display: none;">Bid price error</small>');
        errorMessageEl = $('#bid-price-error');
      }
      
      // Validate price range
      let isValid = true;
      
      // Check for NaN
      if (isNaN(enteredPrice)) {
          toastr.error('Please enter a valid number');
          priceInput.addClass('is-invalid');
          errorMessageEl.text('Please enter a valid number').show();
          isValid = false;
      }
      // Check if below minimum
      else if (enteredPrice < minPrice) {
          toastr.error(`The price cannot be less than 95% of the base price, which is $${minPrice}`);
          priceInput.addClass('is-invalid');
          errorMessageEl.text(`Bid price must be at least $${minPrice} (95% of base price)`).show();
          isValid = false;
      }
      // Check if above maximum 
      else if (enteredPrice > basePrice) {
          toastr.error(`The bid price cannot exceed the base price of $${basePrice}. Please correct your bid.`);
          priceInput.addClass('is-invalid');
          errorMessageEl.text(`Bid cannot exceed base price of $${basePrice}`).show();
          isValid = false;
      }
      
      // If validation fails, stop here
      if (!isValid) {
          return false;
      }
      
      // Show loading indicator
      const submitBtn = $(this).find('button[type="submit"]');
      const originalBtnText = submitBtn.text();
      submitBtn.prop('disabled', true).text('Submitting...');
      
      let url = '/update-bid?status=';
      url += (buyer === undefined || buyer === null) ? 'negotiate' : 'buyer';
  
      $.ajax({
        url: url,
        type: 'POST',
        data: {
          bid_id: bidId,
          price: price
        },
        headers: {
          'X-CSRF-Token': csrfToken  
        },
        success: function(response) {
          $('#negotiateModal').modal('hide');
          window.location.href = response.redirect_url;
        },
        error: function(xhr, status, error) {
          // Re-enable button
          submitBtn.prop('disabled', false).text(originalBtnText);
          
          if (xhr.responseJSON && xhr.responseJSON.error) {
            toastr.error(xhr.responseJSON.error);
          } else {
            toastr.error("Error negotiating bid: " + error);
          }
        }
      });
    });
    
    $(document).ready(function () {
      let selectedOrderIds = [];
  
      $(document).on('change', '.order-checkbox', function () {
          // Clear the array to ensure no duplication
          selectedOrderIds = [];
          
          // Gather all checked order IDs
          $('.order-checkbox:checked').each(function() {
              const orderId = $(this).data('id');
              if (!selectedOrderIds.includes(orderId)) {
                  selectedOrderIds.push(orderId);
              }
          });
  
          console.log('Selected Order IDs:', selectedOrderIds);
  
          toggleConsolidateButton(selectedOrderIds.length >= 2);
      });
  
      // Added to global scope for access from buyers_orders.html.erb
      window.toggleConsolidateButton = function(enable) {
          const $button = $('#consolidate-btn');
          if (enable) {
              $button.prop('disabled', false);
              $button.show();
          } else {
              $button.prop('disabled', true);
              $button.hide();
          }
      };
  
      $('#consolidate-btn').on('click', function () {
          if (confirm('Are you sure you want to consolidate the selected orders?')) {
              sendOrderIdsToServer(selectedOrderIds);
          }
      });
  
      function sendOrderIdsToServer(orderIds) {
          $.ajax({
              url: '/consolidate-orders', 
              method: 'POST',
              headers: {
                  'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
              },
              contentType: 'application/json',
              data: JSON.stringify({
                  order_ids: orderIds
              }),
              success: function (response) {
                  toastr.success('Orders consolidated successfully!');
                  console.log('Server response:', response);
                  setTimeout(function() {
                      location.reload();
                  }, 1500);
              },
              error: function (xhr, status, error) {
                  console.error('Error:', xhr.responseJSON);
                  let errorMessage = 'An error occurred while consolidating orders. Please try again.';
                  
                  // Try to get a more specific error message from the response
                  if (xhr.responseJSON && xhr.responseJSON.error) {
                      errorMessage = xhr.responseJSON.error;
                  }
                  
                  toastr.error(errorMessage);
              }
          });
      }
  
      // Initially disable the button
      toggleConsolidateButton(false);
  });
  