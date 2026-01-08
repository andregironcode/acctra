// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

//= require product
//= require statistics
(function($) {
    "use strict"; // Start of use strict
  
    // Toggle the side navigation
    $("#sidebarToggle, #sidebarToggleTop").on('click', function(e) {
      $("#page-top").toggleClass("sidebar-toggled");
      $(".sidebar").toggleClass("toggled");
      $(".sidebar").addClass("sidebar-block");
      $(".sidebar").removeClass("sidebar-none");
     
  

      if ($(".sidebar").hasClass("toggled")) {
        $(".sidebar").addClass("sidebar-none");
        $(".sidebar").removeClass("sidebar-block");
   
        $('.sidebar .collapse').collapse('hide');
      };
    });
  
    // Close any open menu accordions when window is resized below 768px
    $(window).resize(function() {
      if ($(window).width() < 768) {
        $('.sidebar .collapse').collapse('hide');
      };
      
      // Toggle the side navigation when window is resized below 480px
      if ($(window).width() < 480 && !$(".sidebar").hasClass("toggled")) {
        $("#page-top").addClass("sidebar-toggled");
        $(".sidebar").addClass("toggled");
        $('.sidebar .collapse').collapse('hide');
      };
    });
  
    // Prevent the content wrapper from scrolling when the fixed side navigation hovered over
    $('#page-top.fixed-nav .sidebar').on('mousewheel DOMMouseScroll wheel', function(e) {
      if ($(window).width() > 768) {
        var e0 = e.originalEvent,
          delta = e0.wheelDelta || -e0.detail;
        this.scrollTop += (delta < 0 ? 1 : -1) * 30;
        e.preventDefault();
      }
    });
  
    // Scroll to top button appear
    $(document).on('scroll', function() {
      var scrollDistance = $(this).scrollTop();
      if (scrollDistance > 100) {
        $('.scroll-to-top').fadeIn();
      } else {
        $('.scroll-to-top').fadeOut();
      }
    });
  
    // Smooth scrolling using jQuery easing
    $(document).on('click', 'a.scroll-to-top', function(e) {
      var $anchor = $(this);
      $('html, body').stop().animate({
        scrollTop: ($($anchor.attr('href')).offset().top)
      }, 1000, 'easeInOutExpo');
      e.preventDefault();
    });
  
  })(jQuery); // End of use strict
  

const maxValue = Number($('#max-count').text());
let roundedValue = maxValue/4;
$('#firstValue').text(roundedValue * 1)
$('#secondValue').text(roundedValue * 2)
$('#thirdValue').text(roundedValue * 3)
const bars = document.querySelectorAll('.bar');

bars.forEach(bar => {
  const value = parseInt(bar.getAttribute('data-value'), 10);
  
  const percentage = (value / maxValue) * 100;
  const barFill = bar.querySelector('.bar-fill');
  barFill.style.width = percentage + '%';
  barFill.textContent = value;
});


document.addEventListener('DOMContentLoaded', function() {
  var flashMessage = document.querySelector('.flash');

  if (flashMessage) {
    flashMessage.style.transition = 'opacity 3s';
    flashMessage.style.opacity = 1;
    flashMessage.style.visibility = 'visible';  
    setTimeout(function() {
      flashMessage.style.transition = 'opacity 1s';
      flashMessage.style.opacity = 0; 
      flashMessage.style.visibility = 'hidden';
    }, 5000);
  }
});
document.addEventListener('DOMContentLoaded', function() {
  var flashMessage = document.querySelector('.flash');

  if (flashMessage) {
    flashMessage.style.transition = 'opacity 3s';
    flashMessage.style.opacity = 1;
    flashMessage.style.visibility = 'visible';  
    setTimeout(function() {
      flashMessage.style.transition = 'opacity 1s';
      flashMessage.style.opacity = 0; 
      flashMessage.style.visibility = 'hidden';
    }, 5000);
  }
});
toastr.options = {
  "closeButton": true,
  "debug": false,
  "newestOnTop": false,
  "progressBar": true,
  "positionClass": "toast-top-center",
  "preventDuplicates": true,
  "onclick": null,
  "showDuration": "300",
  "hideDuration": "1000",
  "timeOut": "3000",
  "extendedTimeOut": "1000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
}

$(document).ready(function() {
  if ($(window).width() < 480 && !$(".sidebar").hasClass("toggled")) {
    $("#page-top").addClass("sidebar-toggled");
    $(".sidebar").addClass("toggled");
    $('.sidebar .collapse').collapse('show');
  };

  $('#dashDateBtn').on('click', function() {
      $('#dashInputs').toggle();
  });

  $('#statsDateBtn').on('click', function() {
    $('#statsInputs').toggle();
});


  $('#apply-filter-dash').on('click', function() {
    const startDate = $('#dashStartDate').val();
    const endDate = $('#dashEndDate').val();

    const checkStartDate = new Date(startDate);
    const checkEndDate = new Date(endDate);
    if (checkStartDate > new Date()) {
      alert("Start date cannot be in the future. Please select a valid start date.");
      return;
    }
    if (startDate === ''  || !checkStartDate ) {
      alert("Start date must be present. Please select a valid start date.");
      return;
    }
    if (checkEndDate < checkStartDate) {
      alert("End date cannot be before the start date. Please select a valid end date.");
      return;
    }
    $.ajax({
      url: '/dashboard_filter', 
      type: 'GET',
      dataType: 'json',
      data: {
        start_date: startDate,
        end_date: endDate,
      },
    
      success: function(response) {
        $('#dashInputs').hide();
        $('#customDateInputs').hide();
        console.log("Filtered data received:", response);
        console.log("length:", response.orders.length );
        $('#sellersOrders').text(response.orders.length)
        $('#sellersSales').text(`$${response.total_sales}`)
        $('#processingOrders').text(`${response.processing_count}`)
        $('#max-count').text(response.max_count)      
          barsChart(response.sorted_product_counts)
          top_selling(response.top_selling_products)
          recentOrders(response.recent_orders)
          const timestamp = Date.now();
          console.log(timestamp)
          const baseUrl = "/orders-list";
      $("#processing-orders").attr(
        "href",
        `${baseUrl}?order_status=processing&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`
       );

      $("#total-orders").attr(
        "href",
        `${baseUrl}?order_status=&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`
      );
      $("#completed-orders").attr(
        "href",
        `${baseUrl}?order_status=completed&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`
      );
      },
      error: function(error) {
        console.error("Error applying date filter:", error);
        alert("An error occurred while applying the filter.");
      }
    });
  });

});

$('#cancelBtn').on('click', function() {
  $('#dashInputs').hide();
});

$('#statsCancelBtn').on('click', function() {
  $('#statsInputs').hide();
});

$('#dashFilterReset').on('click', function() {
  $('#startDate').val('');
  $('#endDate').val('');
  const startDate = $('#startDate').val();
  const endDate = $('#endDate').val();

  $.ajax({
    url: '/dashboard_filter', 
    type: 'GET',
    dataType: 'json',
    data: {
      start_date: startDate,
      end_date: endDate,
    },
  
    success: function(response) {
      $('#customDateInputs').hide();
      console.log("Filtered data received:", response);
      console.log("length:", response.orders.length );
      $('#sellersOrders').text(response.orders.length)
      $('#sellersSales').text(`$${response.total_sales}`)
      $('#processingOrders').text(`${response.processing_count}`)
      $('#max-count').text(response.max_count)      
      barsChart(response.sorted_product_counts)
      top_selling(response.top_selling_products)
      const timestamp = Date.now();

      const baseUrl = "/orders-list";
      $("#processing-orders").attr(
        "href",
        `${baseUrl}?order_status=processing&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`
       );

      $("#total-orders").attr(
        "href",
        `${baseUrl}?order_status=&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`
      );
    $("#completed-orders").attr(
      "href",
      `${baseUrl}?order_status=completed&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`
    );
    },
    error: function(error) {
      console.error("Error applying date filter:", error);
      alert("An error occurred while applying the filter.");
    }
  });
});

function barsChart (categories){
  const barsContainer = $('.AdminsetHeightBars'); 
  const maxValue = Number($('#max-count').text());
  barsContainer.empty();
  categories.forEach(function(item) {
    let productName = item[0];  
    let productCount = item[1];
    const bar = document.createElement('div');
    bar.classList.add('bar');
    bar.setAttribute('data-value',productCount);

    const label = document.createElement('div');
    label.classList.add('label');
    label.textContent = productName;

    const barContainer = document.createElement('div');
    barContainer.classList.add('bar-container');

    const barFill = document.createElement('div');
    barFill.classList.add('bar-fill');
    const percentage = (productCount / maxValue) * 100; // Calculate the width percentage
    barFill.style.width = percentage + '%'; // Set the width of the bar-fill
    barFill.textContent = productCount; // Set the count as the text inside the bar-fill
    barContainer.append(barFill);
    bar.append(label);
    bar.append(barContainer);
    barsContainer.append(bar);
  });
  const bars = document.querySelectorAll('.bar');
  let roundedValue = maxValue / 4;

  $('#firstValue').text(roundedValue * 1);
  $('#secondValue').text(roundedValue * 2);
  $('#thirdValue').text(roundedValue * 3);
  bars.forEach(bar => {
    const value = parseInt(bar.getAttribute('data-value'), 10);
    const percentage = (value / maxValue) * 100;
    const barFill = bar.querySelector('.bar-fill');
    barFill.style.width = percentage + '%';
    barFill.textContent = value;
  });
}


function top_selling (products){
  const productsContainer = $('#seller-products-container');
  productsContainer.empty();
  if (products.length > 0) {
    products.forEach(function(product) {
      const productHtml = `
        <a href="/products/${product.id}" class="full-width-link">
                    <div class="sellingProducts mt-4">
                      <div class="flag_alignment d-flex gap-3">
                        <div class="productMemory">
                          <span class="flag flag-icon flag-icon-${product.country.toLowerCase()} flag-icon-squared"></span>
                        </div>
                        <div class="productName">
                          <div>${product.name}</div>
                          <div class="productMemory">${product.variant}</div>
                        </div>
                      </div>
                      <div class="productPrice">
                        <div>${Number(product.total_sales).toLocaleString('en-US')}</div>
                        <div class="productSales">${product.total_quantity_sold} sales</div>
                      </div>
                    </div>
                  </a>
      `;
      productsContainer.append(productHtml);
    });
  } else {
    productsContainer.append('<div class="text-center d-flex justify-content-center"><div>No top products present</div></div>');
  }
}
function recentOrders(orders) {
  let tableContent = "";

  if (orders.length > 0) {
      orders.forEach(order => {
              const createdAt = new Date(order.created_at).toLocaleString("en-US", {
                  day: "2-digit",
                  month: "2-digit",
                  year: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                  hour12: true
              });
              const totalPrice = `$${order.total_amount}`;
              tableContent += `
                  <tr class="setBorderBottomTr" onclick="window.location='/order-details/${ order.order_id }'">
                      <td>${order.product_name}</td>
                      <td>${order.sku}</td>
                      <td>${createdAt}</td>
                      <td>${order.quantity}</td>
                      <td>${totalPrice}</td>
                      <td><span class="order-${order.status}">${order.status} <span></td>
                  </tr>
              `;
         
      });
  } else {
      tableContent = `
          <tr>
              <td colspan="12" class="text-center">No recent orders present</td>
          </tr>
      `;
  }
  document.querySelector("#recentOrdersTable tbody").innerHTML = tableContent;
}

  $(".bids-side").on("click", function () {
    $("#bids-side-bar a").toggleClass("d-none d-block");
      $(".arrow").toggleClass("up");  // Rotate the arrow
  });
  document.addEventListener("DOMContentLoaded", function () {
    setTimeout(function () {
      let alertBox = document.querySelector(".alert");
      if (alertBox) {
        alertBox.classList.add("d-none");
      }
    }, 3000);
  });