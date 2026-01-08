//= require arctic_admin/base
//= require admin/products
//= require admin/devices
//= require admin/categories
//= require jquery_easing
//= require custom
//= require bootstrap4
//= require dashboard
//= require chart
//= require admin/brand_stats

let sellerChart

$(document).ready(function() {
  const bars = document.querySelectorAll('.bar');
  const maxValue = Number($('#max-count').text());
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

  

// stats page total orders
  const statsBars = document.querySelectorAll('.order-bar');
  const maxStatsValue = Number($('#maxStatsValue').text());
  let statsRoundedValue = maxStatsValue / 4;
  $('#firstStatsValue').text(statsRoundedValue * 1);
  $('#secondStatsValue').text(statsRoundedValue * 2);
  $('#thirdStatsValue').text(statsRoundedValue * 3);
  statsBars.forEach(statsBar => {
    const value = parseInt(statsBar.getAttribute('data-value'), 10);
    const percentage = (value / maxStatsValue) * 100;
    const barFill = statsBar.querySelector('.bar-fill-statics');
    barFill.style.width = percentage + '%';
  });


  const CategoryBars = document.querySelectorAll('.categoryBar');
  const maxCatValue = Number($('#maxCategoryValue').text().trim().replace(/[$,]/g, '') );
  let catRoundedValue = maxCatValue / 4;
  $('#firstCatValue').text(`$${Number((catRoundedValue * 1).toFixed(0)).toLocaleString('en-US')}`);
  $('#secondCatValue').text(`$${Number((catRoundedValue * 1).toFixed(0)).toLocaleString('en-US')}`)
  $('#thirdCatValue').text(`$${Number((catRoundedValue * 1).toFixed(0)).toLocaleString('en-US')}`)
  
  CategoryBars.forEach(catBar => {
    const value = parseInt(catBar.getAttribute('data-value'), 10);
    const percentage = (value / maxCatValue) * 100;
    const barFill = catBar.querySelector('.bar-fill-statics-category');
    barFill.style.width = percentage + '%';
  });
// Initialize arrays for labels and data
const labels = [];
const dataValues = [];

// Loop through each span element and extract total revenue and last name
document.querySelectorAll('span[id^="topSeller"]').forEach((span) => {
  const totalRevenue = span.getAttribute('data-value');
  const lastName = span.getAttribute('data-lastName');

  // Add last name to labels and total revenue to dataValues
  labels.push(lastName);
  dataValues.push(totalRevenue);
});

// Now use the labels and dataValues in the chart
const ctx = document.getElementById("apexcharts-bar").getContext("2d");

sellerChart = new Chart(ctx, {
  type: "bar",
  data: {
    labels: labels,  // Using last names as labels
    datasets: [
      {
        label: "Total Revenue",
        backgroundColor: "rgba(54, 162, 235, 0.7)",
        borderColor: "rgba(54, 162, 235, 1)",
        data: dataValues,  // Using total revenue as the data values
        barPercentage: 0.75,
        categoryPercentage: 0.5,
      },
    ],
  },
  options: {
    tooltips: {
      enabled: true,
      callbacks: {
        // Customize the label displayed in the tooltip
        label: function(tooltipItem, data) {
          // Get the raw value (total revenue) from the tooltip item
          const value = tooltipItem.yLabel;
          // Format it as a dollar value with commas
          return '$' + value.toLocaleString();
        }
      }
    },
    scales: {
      yAxes: [{
        ticks: {
          beginAtZero: true,
          callback: function(value) {
            // Format the tick value with a dollar sign and commas
            return '$' + value.toLocaleString();
          }
        },
        gridLines: {
          display: false  // Disable Y-axis grid lines
        }
      }],
      xAxes: [{
        ticks: {
          // Add custom tick settings if necessary
        },
        gridLines: {
          display: false // Set the color of grid lines for the X-axis
        }
      }],
    },
  },
});




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
$(document).ready(function() {
  $('#calender').on('click', function() {
    $('#customDateInputs').toggle();
  });

  $('#apply-admin-filter-dash').on('click', function() {
    const startDate = $('#adminDashStartDate').val();
    const endDate = $('#adminDashEndDate').val();
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
      url: '/admin/dashboard/dashboard_filter', 
      type: 'GET',
      dataType: 'json',
      data: {
        start_date: startDate,
        end_date: endDate || '',
      },
    
      success: function(response) {
        $('#customDateInputs').hide();
        console.log("Filtered data received:", response);
        console.log("length:", response.orders.length );
        $('#total_orders').text(response.orders.length)
        $('#total_sales').text(`$${response.total_sales}`)
        $('#processing_count').text(`${response.processing_count}`)
        $('#max-count').text(response.max_count)      
          barsChart(response.sorted_product_counts)
          top_selling(response.top_selling_products)
          recentOrders(response.recent_orders)
          let all = generateOrderUrl(startDate,  endDate , 'all')
          let processing = generateOrderUrl(startDate,  endDate , 'processing')
          let sales = generateOrderUrl(startDate,  endDate , 'completed')
          $('#all').attr('href', all);
          $('#sales').attr('href', sales);
          $('#processing').attr('href', processing);
      },
      error: function(error) {
        console.error("Error applying date filter:", error);
        alert("An error occurred while applying the filter.");
      }
    });
  });

  $('#cancelBtn').on('click', function() {
    $('#customDateInputs').hide();
    $('#startDate').val('');
    $('#endDate').val('');
  });

  $('#statsCancelBtn').on('click', function() {
    $('#customDateInputs').hide();
    $('#statsStartDate').val('');
    $('#statsEndDate').val('');
  });

  $('#statsReset').on('click', function() {

    $('#adminStatsStartDate').val('');
    $('#adminStatsEndDate').val('');
    const startDate = $('#adminStatsStartDate').val();
    const endDate = $('#adminStatsEndDate').val();
    $.ajax({
      url: '/admin/statistics_filter', 
      type: 'GET',
      dataType: 'json',
      data: {
        start_date: startDate,
        end_date: endDate || '',
      },
    
      success: function(response) {
        console.log("Filtered data received:", response);
        ordersStats(response, startDate, endDate)
        categorySales(response)
        topSeller (response)
        statstopSelling(response.top_selling_products)
      },
      error: function(error) {
        console.error("Error applying date filter:", error);
        alert("An error occurred while applying the filter.");
      }
    });
  
  })

  $('#adminDashFilterReset').on('click', function() {
    $('#adminDashStartDate').val('');
    $('#adminDashEndDate').val('');
    const startDate = $('#startDate').val();
    const endDate = $('#endDate').val();
    $.ajax({
      url: '/admin/dashboard/dashboard_filter', 
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
        $('#total_orders').text(response.orders.length)
        $('#total_sales').text(`$${response.total_sales}`)
        $('#processing_count').text(`${response.processing_count}`)
        $('#max-count').text(response.max_count)   
   
          barsChart(response.sorted_product_counts)
          top_selling(response.top_selling_products)
          recentOrders(response.recent_orders)
          let all = generateOrderUrl(startDate,  endDate , 'all')
          let processing = generateOrderUrl(startDate,  endDate , 'processing')
          let sales = generateOrderUrl(startDate,  endDate , 'completed')
          $('#all').attr('href', all);
          $('#sales').attr('href', sales);
          $('#processing').attr('href', processing);
      },
      error: function(error) {
        console.error("Error applying date filter:", error);
        alert("An error occurred while applying the filter.");
      }
    });
  });

  $('#statsApplyCustomDate').on('click', function() {
    const startDate = $('#adminStatsStartDate').val();
    const endDate = $('#adminStatsEndDate').val();
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
      url: '/admin/statistics_filter', 
      type: 'GET',
      dataType: 'json',
      data: {
        start_date: startDate,
        end_date: endDate || '',
      },
    
      success: function(response) {
        console.log("Filtered data received:", response);
        ordersStats(response, startDate, endDate)
        categorySales(response)
        topSeller (response)
        statstopSelling(response.top_selling_products)
      },
      error: function(error) {
        console.error("Error applying date filter:", error);
        alert("An error occurred while applying the filter.");
      }
    });
  });

});

function recentOrders(orders) {
  let tableContent = "";

  if (orders.length > 0) {
      orders.forEach(order => {
              const sellerLink = `<a href="/admin/users/${order.seller_id}">${order.seller_name}</a>`;
              const productLink = `<a href="/admin/products/${order.product_id}">${order.product_name}</a>`;
              const createdAt = new Date(order.created_at).toLocaleString("en-US", {
                  day: "2-digit",
                  month: "2-digit",
                  year: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                  hour12: true
              });
              const totalPrice = `$${order.total_amount}`;

              let statusClass = "";
              switch (order.status) {
                  case "created":
                      statusClass = "bg-new";
                      break;
                  case "processing":
                      statusClass = "bg-process";
                      break;
                  case "dispatched":
                      statusClass = "bg-secondary";
                      break;
                  case "completed":
                      statusClass = "bg-completed";
                      break;
              }

              const statusBadge = `<button class="badge-status text-light ${statusClass}">${order.status}</button>`;
              const orderLink = `<a href="/admin/orders/${order.order_id}">View Order</a>`;

              tableContent += `
                  <tr class="setBorderBottomTr"  onclick="window.location='/admin/orders/${order.order_id}'">
                      <td>${sellerLink}</td>
                      <td>${productLink}</td>
                      <td>${order.sku}</td>
                      <td>${createdAt}</td>
                      <td>${order.quantity}</td>
                      <td>${totalPrice}</td>
                      <td>${statusBadge}</td>
                      <td>${orderLink}</td>
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
  const productsContainer = $('#products-container');
  productsContainer.empty();
  if (products.length > 0) {
    products.forEach(function(product) {
      const productHtml = `
        <a href="admin/products/${product.id}" class="full-width-link">
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
                        <div> $${Number(product.total_sales).toLocaleString('en-US')}</div>
                        <div class="productSales">${product.total_quantity_sold} sales</div>
                      </div>
                    </div>
                  </a>
      `;
      productsContainer.append(productHtml);
    });
  } else {
    productsContainer.append('<div class="text-center d-flex justify-content-center align-items-center"><div>No top products present</div></div>');
  }
}

function generateOrderUrl(startDate, endDate, scope) {
  const baseUrl = `/admin/orders?order=id_desc&scope=${scope}`;
  
  // Encode the dates to ensure proper URL formatting
  const startDateEncoded = encodeURIComponent(startDate);
  const endDateEncoded = encodeURIComponent(endDate);
  
  const url = `${baseUrl}&q%5Bcreated_at_gteq%5D=${startDateEncoded}&q%5Bcreated_at_lteq%5D=${endDateEncoded}`;
  
  return url;
}
function ordersStats(response, startDate, endDate){

  let adjustedEndDate;
if (endDate) {
  const end = new Date(endDate); // Convert to a Date object
  end.setDate(end.getDate() + 1); // Add one day
  adjustedEndDate = end.toISOString().split('T')[0]; // Format as YYYY-MM-DD
}
  $('#maxStatsValue').text(response.max_order_count)
        const maxStatsValue = Number($('#maxStatsValue').text());
          let statsRoundedValue = maxStatsValue / 4;
          $('#firstStatsValue').text(statsRoundedValue * 1);
          $('#secondStatsValue').text(statsRoundedValue * 2);
          $('#thirdStatsValue').text(statsRoundedValue * 3);
          const statsBars = document.querySelectorAll('.order-bar');
        if (response.max_order_count >= 0 ){
          statsBars.forEach(statsBar => {
            const value = parseInt(statsBar.getAttribute('data-value'), 10);
            let newValue;
            let barFill;
            let label;
          
            if (statsBar.querySelector('.label-statics a').href.includes('new')) {
              newValue = response.new_count;
              barFill = statsBar.querySelector('.bar-fill-statics');
              label = 'New';
              newHref = `/admin/orders/?scope=new&order=id_desc&q[created_at_gteq]=${startDate || ''}&q[created_at_lteq]=${adjustedEndDate || ''}`;
              statsBar.querySelector('.label-statics a').href = newHref;
            } else if (statsBar.querySelector('.label-statics a').href.includes('processing')) {
              newValue = response.processing_count;
              barFill = statsBar.querySelector('.bar-fill-statics-proces');
              label = 'Processing';
              newHref = `/admin/orders/?scope=processing&order=id_desc&q[created_at_gteq]=${startDate || ''}&q[created_at_lteq]=${adjustedEndDate || ''}`;
              statsBar.querySelector('.label-statics a').href = newHref;
            } else if (statsBar.querySelector('.label-statics a').href.includes('completed')) {
              newValue = response.completed_count;
              barFill = statsBar.querySelector('.bar-fill-statics-cmplt');
              label = 'Completed';
              newHref = `/admin/orders/?scope=completed&order=id_desc&q[created_at_gteq]=${startDate || ''}&q[created_at_lteq]=${adjustedEndDate || ''}`;
              statsBar.querySelector('.label-statics a').href = newHref;
            }
            statsBar.setAttribute('data-value', newValue);
            statsBar.querySelector('.dolarSet span').textContent = newValue;
            const percentage = (newValue / maxStatsValue) * 100;
            barFill.style.width = `${percentage}%`;
          });
        }else{
          statsBars.forEach(statsBar => {
            const value = parseInt(statsBar.getAttribute('data-value'), 10);
            let newValue;
            let barFill;
            let label;
            barFill = statsBar.querySelector('.bar-fill-statics');
            
          statsBar.setAttribute('data-value', 0);
            statsBar.querySelector('.dolarSet span').textContent = 0;
            barFill.style.width = `0%`;
          });
        }
}



function categorySales(response){
    $('#maxCategoryValue').text(`$${response.max_category_sales}`)
      const maxCatValue = Number($('#maxCategoryValue').text().replace('$', '') );

      const catRoundedValue = maxCatValue / 4;
      $('#firstCatValue').text(`$${(catRoundedValue * 1).toFixed(1)}`);
      $('#secondCatValue').text(`$${(catRoundedValue * 2).toFixed(1)}`);
      $('#thirdCatValue').text(`$${(catRoundedValue * 3).toFixed(1)}`);
      const categorySalesContainer = document.querySelector('.category-sales');

      categorySalesContainer.innerHTML = '';
      if (response.sorted_category_sales.length > 0 ) {
        response.sorted_category_sales.forEach((category, index) => {
        // Create new category bar div
        const categoryBar = document.createElement('div');
        categoryBar.classList.add('category-bar', 'categoryBar');
        categoryBar.setAttribute('data-value', category.sales);

        // Create the content for the new category bar
        const categoryLink = document.createElement('a');
        categoryLink.href = `/admin/categories/${category.id}`;

        const labelDiv = document.createElement('div');
        labelDiv.classList.add('label-statics-category');
        const labelSpan = document.createElement('span');
        labelSpan.textContent = category.name;
        labelDiv.appendChild(labelSpan);

        const barContainerDiv = document.createElement('div');
        barContainerDiv.classList.add('bar-container-statics-category', 'd-flex', 'align-items-center');

        const barFillDiv = document.createElement('div');
        barFillDiv.classList.add('bar-fill-statics-category', `category${index+1}`); // Add category{index} class

        barFillDiv.style.width = `${(parseFloat(category.sales) / maxCatValue) * 100}%`;

        const dollarSetDiv = document.createElement('div');
        dollarSetDiv.classList.add('dolarSet', 'ml-1');
        const dollarSpan = document.createElement('span');
        dollarSpan.textContent = `$${category.sales}`;
        dollarSetDiv.appendChild(dollarSpan);

        // Assemble the category bar structure
        barContainerDiv.appendChild(barFillDiv);
        barContainerDiv.appendChild(dollarSetDiv);

        categoryLink.appendChild(labelDiv);
        categoryBar.appendChild(categoryLink);
        categoryBar.appendChild(barContainerDiv);

        // Append the new category bar to the container
        categorySalesContainer.appendChild(categoryBar);
        });
      }else{
        $('#firstCatValue').text(`0`);
        $('#secondCatValue').text(`0`);
        $('#thirdCatValue').text(`0`)
        $('#maxCategoryValue').text('0')
      categorySalesContainer.innerHTML = '<h4> No data found </h4>';
      $('#model-sales').addClass('d-flex align-items-center justify-content-center')
      }
}
function topSeller (response){
  $('#top-sellers').empty();
  sellerChart.destroy()

  if (response.top_sellers.length > 0 ) {
        response.top_sellers.forEach(function(seller, index) {
          $('#top-sellers').append(
            `<span id="topSeller${index}" class="d-none" data-value="${seller.total_revenue}" data-lastname="${seller.last_name}">
              ${seller.last_name} - ${seller.total_revenue}
            </span>`
          );
        });
      const newCanvas = document.getElementById("apexcharts-bar");
      const labels = [];
      const dataValues = [];
      document.querySelectorAll('#top-sellers span[id^="topSeller"]').forEach((span) => {
        const totalRevenue = span.getAttribute('data-value');
        const lastName = span.getAttribute('data-lastname');  // Corrected attribute name to 'data-lastname'
        labels.push(lastName);
        dataValues.push(totalRevenue);
      });

     new Chart(newCanvas.getContext("2d"), {
      type: "bar",
      data: {
        labels: labels,  // Using last names as labels
        datasets: [
          {
            label: "Total Revenue",
            backgroundColor: "rgba(54, 162, 235, 0.7)",
            borderColor: "rgba(54, 162, 235, 1)",
            data: dataValues,  // Using total revenue as the data values
            barPercentage: 0.75,
            categoryPercentage: 0.5,
          },
      ],
    },
    options: {
      maintainAspectRatio: false,
      tooltips: {
        enabled: true,
        callbacks: {
          // Customize the label displayed in the tooltip
          label: function(tooltipItem, data) {
            // Get the raw value (total revenue) from the tooltip item
            const value = tooltipItem.yLabel;
            // Format it as a dollar value with commas
            return '$' + value.toLocaleString();
          }
        }
      },
      scales: {
        yAxes: [{
          ticks: {
            beginAtZero: true,
            callback: function(value) {
              // Format the tick value with a dollar sign and commas
              return '$' + value.toLocaleString();
            }
          },
          gridLines: {
            display: false  // Disable Y-axis grid lines
          }
        }],
        xAxes: [{
          ticks: {
            // Add custom tick settings if necessary
          },
          gridLines: {
            display: false // Set the color of grid lines for the X-axis
          }
        }],
      },
    }})
  }else{
    $('#apexcharts-bar').remove()
    $('.chart-wrapper-seller').addClass('align-items-center justify-content-center' )
    $('.chart-wrapper-seller').append(`<h4 class="mb-0"> No Data Found </h4>`);
    $('.chart-wrapper-seller').css('height', '20.9rem');


  }
}
function statstopSelling (products){
  const productsContainer = $('#top-products');
  productsContainer.empty();
  if (products.length > 0) {
    products.forEach(function(product) {
      const productHtml = `
       <a href="admin/products/${product.id}" class="full-width-link">
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
                        <div>$${Number(product.total_sales).toLocaleString('en-US')}</div>
                        <div class="productSales">${product.total_quantity_sold} sales</div>
                      </div>
                    </div>
                  </a>
      `;
      productsContainer.append(productHtml);
    });
  } else {
    productsContainer.append('<div class="d-flex justify-content-center align-items-center"><div>No top products present</div></div>');
  }
}

$(document).on('input', '.order-item-quantity, .order-item-price', function() {
  let totalAmount = 0;

  $('.order-item-quantity').each(function(index) {
    const quantity = parseFloat($(this).val()) || 0;
    const price = parseFloat($('.order-item-price').eq(index).val()) || 0;
    totalAmount += quantity * price;
  });

  $('#order_total_amount').val(totalAmount.toFixed(2)); // Update total amount field
});

document.addEventListener("DOMContentLoaded", function () {
  setTimeout(function () {
    let alertBox = document.querySelector(".alert");
    let flashes = document.querySelector(".flashes");

    if (alertBox) {
      alertBox.classList.add("d-none");
    }

    if (flashes) {
      flashes.classList.add("d-none");
    }
  }, 3000);
});