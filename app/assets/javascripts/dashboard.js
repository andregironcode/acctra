$(document).ready(function() {
    $('.monthNamesInput').on('change', function() {
      var selectedOption = $(this).val();
  
      $.ajax({
        url: '/admin/dashboard/recent_orders',
        method: 'GET',
        data: {
          filter: selectedOption
        },
        success: function(response) {
          // Remove previous table data
          $('tbody.setFontOrderTable').empty();
  
          // Append the new table data
          $('tbody.setFontOrderTable').append(response);
        },
        error: function(xhr, status, error) {
          console.error('Error:', error);
        }
      });
    });
  });
  