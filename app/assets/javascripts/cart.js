// Functions for cart operations

function calculateTotalPrice() {
  let totalPrice = 0;
  $('.total-price').each(function() {
    const price = $(this).text().replace(/[^\d.]/g, '');
    totalPrice += parseFloat(price) || 0;
  });
  
  // Format as currency and update the total
  $('#total-cart-price').text('Total = $' + totalPrice.toLocaleString());
  
  // If no items left, hide checkout button
  if ($('.total-price').length === 0) {
    $('.submitBtnCart').hide();
  }
}

function updateCart(cart_id, quantity, calculate, id, beforeInputQuantity) {
  const csrfToken = $('meta[name="csrf-token"]').attr('content');
  
  $.ajax({
    url: '/update_cart_items',  
    type: 'PATCH',        
    data: {
      cart_id: cart_id,    
      quantity: quantity,
      calculate: calculate
    },
    headers: {
      'X-CSRF-Token': csrfToken
    },
    success: function(response) {
      // Update the updated_at timestamp for the timer
      const newUpdatedAt = Math.floor(new Date(response.cart_item.updated_at).getTime() / 1000) * 1000;
      const $timerElement = $(`.timer[data-id="${cart_id}"]`);
      $timerElement.attr('data-updated-at', newUpdatedAt);
      $timerElement.text('15:00');
      
      // Update the stock display based on the response
      const quantityValue = Number($(`#${id}-quantity`).val());
      $(`#${id}-quantity`).attr('data-quantity', quantityValue);
      
      // Get the new stock from the response, if available
      if (response.cart_item && response.cart_item.inventory) {
        $(`#${id}-stock`).text(response.cart_item.inventory.stock_quantity);
      }
    },
    error: function(xhr, status, error) {
      console.error('Error updating cart:', error);
      if (xhr.responseJSON && xhr.responseJSON.error) {
        alert(xhr.responseJSON.error);
      } else {
        alert('Error updating cart. Please try again.');
      }
    }
  });
}

function cartInputChange(event, cartItemId) {
  let inventory_id = event.target.getAttribute('data-inventory');
  let value = parseInt(event.target.value);
  
  if (isNaN(value) || value <= 0) {
    alert("Quantity must be greater than 0");
    event.target.value = 1;
    return;
  }
  
  let priceText = $(`#${inventory_id}-base-price`).text(); 
  let price = priceText.trim().replace(/[$,]/g, '');
  let beforeInputQuantity = parseInt(event.target.getAttribute('data-quantity'));
  
  // Update the UI immediately (optimistic update)
  $(`#${inventory_id}-quantity`).val(value);
  $(`#${inventory_id}-total-price`).text(`$${(Number(price) * value).toLocaleString('en-US')}`);
  calculateTotalPrice();
  
  // Send the update to the server
  updateCart(cartItemId, value, "input", inventory_id, beforeInputQuantity);
}

function minus(id, cartItemId) {
  let quantity = $(`#${id}-quantity`);
  let currentValue = parseInt(quantity.val());
  
  if (currentValue > 1) {
    let newValue = currentValue - 1;
    let priceText = $(`#${id}-base-price`).text(); 
    let price = priceText.trim().replace(/[$,]/g, '');
    
    // Update the quantity input and total price display
    quantity.val(newValue);
    $(`#${id}-total-price`).text(`$${(Number(price) * newValue).toLocaleString('en-US')}`);
    calculateTotalPrice();
    
    // Send the update to the server
    updateCart(cartItemId, newValue, "minus", id);
  } else if (currentValue === 1) {
    // If quantity would become 0, remove the item instead
    deleteItem(cartItemId);
  }
}

function plus(id, cartItemId) {
  let quantity = $(`#${id}-quantity`);
  let currentValue = parseInt(quantity.val());
  let newValue = currentValue + 1;
  let priceText = $(`#${id}-base-price`).text(); 
  let price = priceText.trim().replace(/[$,]/g, '');
  
  // Update the quantity input and total price display
  quantity.val(newValue);
  $(`#${id}-total-price`).text(`$${(Number(price) * newValue).toLocaleString('en-US')}`);
  calculateTotalPrice();
  
  // Send the update to the server
  updateCart(cartItemId, newValue, "plus", id);
}

function deleteItem(cartItemId) {
  // Find the cart item element
  const cartItemElement = $(`#cart-item-${cartItemId}`);
  
  // Skip if the element isn't found (already deleted)
  if (cartItemElement.length === 0) {
    return;
  }
  
  // For manual deletion (not timer expiration), ask for confirmation
  if (event && event.type === 'click') {
    if (!confirm("Are you sure you want to remove this item from your cart?")) {
      return;
    }
  }
  
  // Add a processing class to prevent double-deletion
  cartItemElement.addClass('processing-delete');
  
  const csrfToken = $('meta[name="csrf-token"]').attr('content');
  
  $.ajax({
    url: '/delete_item',
    method: 'DELETE',
    data: { id: cartItemId },
    headers: { 'X-CSRF-Token': csrfToken },
    success: function(response) {
      // Remove the cart item from the page
      cartItemElement.remove();
      calculateTotalPrice();
      
      // Update the displayed stock quantity if it's present
      if (response.inventory_id && response.new_stock) {
        $(`#${response.inventory_id}-stock`).text(response.new_stock);
      }
      
      // Check if we need to display the empty cart message
      if ($('#cart-table tbody tr').length === 1) {
        $('#cart-data').html(`<h2 class="text-center">No cart items present</h2>`);
      }
    },
    error: function(xhr, status, error) {
      // Remove the processing class so it can be tried again
      cartItemElement.removeClass('processing-delete');
      
      console.error('Error deleting cart item:', error);
      if (xhr.responseJSON && xhr.responseJSON.error) {
        toastr.error(xhr.responseJSON.error);
      } else {
        toastr.error("Error removing item from cart. Please try again.");
      }
    }
  });
} 