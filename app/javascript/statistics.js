//= require chart
let topModelsChart 
$(document).ready(function() {
   
  // seller stats page total orders
  
    const statsBars = document.querySelectorAll('.seller-orders');
    const maxStatsValue = Number($('#maxSellerStatsValue').text());
    let statsRoundedValue = maxStatsValue / 4;
    $('#firstSellerStatsValue').text(statsRoundedValue * 1);
    $('#secondSellerStatsValue').text(statsRoundedValue * 2);
    $('#thirdSellerStatsValue').text(statsRoundedValue * 3);
    statsBars.forEach(statsBar => {
      const value = parseInt(statsBar.getAttribute('data-value'), 10);
      const percentage = (value / maxStatsValue) * 100;
      const barFill = statsBar.querySelector('.bar-fill-seller');
      barFill.style.width = percentage + '%';
    });
  
  
    const CategoryBars = document.querySelectorAll('.categoryBar');
    const maxCatValue = Number($('#maxCategoryValue').text().trim().replace(/[$,]/g, '') );
    let catRoundedValue = maxCatValue / 4;
    $('#firstCatValue').text(`$${Number((catRoundedValue * 1).toFixed(0)).toLocaleString('en-US')}`);
    $('#secondCatValue').text(`$${Number((catRoundedValue * 2).toFixed(0)).toLocaleString('en-US')}`)
    $('#thirdCatValue').text(`$${Number((catRoundedValue * 3).toFixed(0)).toLocaleString('en-US')}`)
    
    CategoryBars.forEach(catBar => {
      const value = parseInt(catBar.getAttribute('data-value'), 10);
      const percentage = (value / maxCatValue) * 100;
      const barFill = catBar.querySelector('.bar-fill-statics-category');
      barFill.style.width = percentage + '%';
    });

    $('.monthNamesInput').on('change', function() {
      var selectedFilter = $(this).val();
      $.ajax({
        url: '/dashboard',
        method: 'GET',
        data: { filter: selectedFilter },
        dataType: 'script',
        success: function(response) {
          
        },
        error: function(xhr, status, error) {
          console.log('Error: ' + error);
        }
      });
    });
  
  });

  $(document).on('click', '#seller-brand-stats', function (event) {
    event.preventDefault();
    const dataId = $(this).data('id');
    const brand_sales = $(this).data('sales');
    $('#SellerbrandStatsModal').modal('show');
    $.ajax({
        url: 'sellers_brand_stats_devices', 
        type: 'GET',                
        data: { id: dataId },      
        dataType: 'json',     
        success: function (response) {
            $('.products-list').remove()
            let modalContent = '';
            modalContent += `
            <h4 class="text-center"> BRAND </h4>
                    <div class="category-bar deviceBarBrand " data-value="${brand_sales}">
                            <div class="label-statics-category-stats stats-modal">
                                <span style="text-decoration: underline">${response.brand_name}</span>
                            </div>

                        <div class="bar-container-statics-category  d-flex align-items-center">
                            <div class="bar-fill-stats category1 brand-stats-1">
                            </div>
                            <div class="dolarSetStats ml-1">
                                <span data-toggle="tooltip" data-placement="bottom" title="$${Number(brand_sales).toLocaleString('en-US')}">$${Number(brand_sales).toLocaleString('en-US')}</span>
                            </div>
                        </div>
                    </div>
                            <h4 class="text-center"> DEVICES </h4>    
                `
            response.brand_sales.forEach(function(device, index) {
                modalContent += `
                    <div class="category-bar deviceBarDevice" data-value="${device.sales}">
                            <div class="label-statics-category-stats stats-modal">
                                <span id="sellers-model-stats" class="model-stats" data-brand-id="${dataId}" data-device="${device.name}">${device.name}</span>
                            </div>

                        <div class="bar-container-statics-category d-flex align-items-center">
                            <div class="bar-fill-stats category${index + 1}">
                            </div>
                            <div class="dolarSetStats ml-1">
                                <span data-toggle="tooltip" data-placement="bottom" title="$${Number(device.sales).toLocaleString('en-US')}">$${Number(device.sales).toLocaleString('en-US')}</span>
                            </div>
                        </div>
                    </div>
                `;
            });

            $('#SellerbrandStatsModal .modal-body').html(modalContent);
            barsChartStats('deviceBarBrand', brand_sales)
            barsChartStats('deviceBarDevice', response.brand_sales.length > 0 ?  response.brand_sales[0].sales : 0)
        },
        error: function (xhr, status, error) {
            console.error('AJAX Error:', error);
            $('#SellerbrandStatsModal .modal-body').html('<p>Error loading data. Please try again.</p>');
        }
    });
});



$(document).on('click', '#sellers-model-stats', function (event) {
  event.preventDefault();

  const name = $(this).data('device');
  const brandId = $(this).data('brand-id');
  
  $('.sellers-model-stats').css('text-decoration', 'none');
  $(this).css('text-decoration', 'underline');
  
  $.ajax({
      url: '/sellers_brand_stats_models', 
      type: 'GET',                
      data: { name: name , brand_id: brandId},      
      dataType: 'json',     
      success: function (response) {
          let modalContent = '';
          $('.models-list').remove()
          $('.products-list').remove()

          modalContent += `
          <div class="models-list">
          <h4 class="text-center"> MODELS </h4>`
              response.models_sales.forEach(function(model, index) {
              modalContent += `
                  <div class="category-bar deviceBarModels" data-value="${model.sales}">
                          <div class="label-statics-category-stats stats-modal">
                              <span id="sellers-products-stats" class="products-stats" data-model = "${model.name}">${model.name}</span>
                          </div>

                      <div class="bar-container-statics-category d-flex align-items-center">
                          <div class="bar-fill-stats category${index + 1} models-stats${index + 1}" ;">
                          </div>
                          <div class="dolarSetStats ml-1">
                              <span data-toggle="tooltip" data-placement="bottom" title="$${Number(model.sales).toLocaleString('en-US')}">$${Number(model.sales).toLocaleString('en-US')}</span>
                          </div>
                      </div>
                  </div>
              `;
          });
          modalContent += `</div>`
          $('#SellerbrandStatsModal .modal-body').append(modalContent);
          barsChartStats('deviceBarModels', response.models_sales.length > 0 ?  response.models_sales[0].sales : 0)

      },
      error: function (xhr, status, error) {
          console.error('AJAX Error:', error);
          $('#SellerbrandStatsModal .modal-body').html('<p>Error loading data. Please try again.</p>');
      }
  });
});


$(document).on('click', '#sellers-products-stats', function (event) {
  event.preventDefault();

  const name = $(this).data('model');
  $('.products-stats').css('text-decoration', 'none');
  $(this).css('text-decoration', 'underline');
  
  $.ajax({
      url: '/sellers_brand_stats_products', 
      type: 'GET',                
      data: { name: name },      
      dataType: 'json',     
      success: function (response) {
          let modalContent = '';
          $('.products-list').remove()
          modalContent += `
          <div class="products-list">
          <h4 class="text-center"> PRODUCTS </h4>`
              response.models_sales.forEach(function(model, index) {
              modalContent += `
                  <div class="category-bar deviceBarProducts" data-value="${model.sales}">
                  <a href ="/products/${model.id}/">
                          <div class="label-statics-category-stats stats-modal">
                              <span  data-device = "${model.name}">${model.name} (${model.variant})</span>
                          </div>  
                  </a>
                      <div class="bar-container-statics-category d-flex align-items-center">
                          <div class="bar-fill-stats category${index + 1} product${index + 1} " ;">
                           
                          </div>
                          <div class="dolarSetStats ml-1">
                              <span data-toggle="tooltip" data-placement="bottom" title="$${Number(model.sales).toLocaleString('en-US')}">$${Number(model.sales).toLocaleString('en-US')}</span>
                          </div>
                      </div>
                  </div>
              `;
          });
          modalContent += `</div>`
          $('#SellerbrandStatsModal .modal-body').append(modalContent);
          barsChartStats('deviceBarProducts', response.models_sales.length > 0 ?  response.models_sales[0].sales : 0)
      },
      error: function (xhr, status, error) {
          console.error('AJAX Error:', error);
          $('#SellerbrandStatsModal .modal-body').html('<p>Error loading data. Please try again.</p>');
      }
  });
});



function barsChartStats (selector, maxValue){
  const bars = document.querySelectorAll(`.${selector}`)
  bars.forEach(bar => {
    const value = parseInt(bar.getAttribute('data-value'), 10);
    const percentage = (value / maxValue) * 100;
    const barFill = bar.querySelector('.bar-fill-stats');
    barFill.style.width = percentage + '%';
  });
}
document.addEventListener("DOMContentLoaded", function () {
    const ctx = document.getElementById("top-selling-models").getContext("2d");

    const labelsSet = new Set();
    const salesData = {};

    // Month mapping for proper sorting
    const monthOrder = {
      January: "01",
      February: "02",
      March: "03",
      April: "04",
      May: "05",
      June: "06",
      July: "07",
      August: "08",
      September: "09",
      October: "10",
      November: "11",
      December: "12",
    };

    // Extract data from spans
    document.querySelectorAll(".topSeller").forEach((span) => {
      const model = span.getAttribute("data-model");
      const monthYear = span.getAttribute("data-month"); // e.g., "January 2025"
      const sales = parseFloat(span.getAttribute("data-sales"));

      labelsSet.add(monthYear);

      if (!salesData[model]) {
        salesData[model] = {};
      }
      salesData[model][monthYear] = sales;
    });

    // Sort labels by year and month
    const labels = Array.from(labelsSet).sort((a, b) => {
      const [monthA, yearA] = a.split(" ");
      const [monthB, yearB] = b.split(" ");
      return yearA - yearB || monthOrder[monthA] - monthOrder[monthB];
    });

    const datasets = [];
    const colors = ["#FF5733", "#4285F4", "#34A853", "#FBBC05", "#AB47BC"];
    Object.keys(salesData).forEach((model, index) => {
      datasets.push({
        label: model,
        data: labels.map((month) => salesData[model][month] || 0),
        borderColor: colors[index % colors.length],
        backgroundColor: colors[index % colors.length] + "33",
        fill: false,
        tension: 0.4,
      });
    });

    topModelsChart =  new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: datasets,
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: true, position: "right" },
          tooltip: {
            callbacks: {
              label: function (tooltipItem) {
                return `$${tooltipItem.raw.toLocaleString()}`; // Ensure $ in tooltip
              },
            },
          },
        },
        scales: {
          yAxes: [{
              ticks: {
                  beginAtZero: true,
                  userCallback: function(value) {
                    return `$${value.toLocaleString()}`; // Ensure $ on Y-axis
 
                  },
              }
          }],
        },
      },
    });
  });

  $('#statsDateFilter').on('click', function() {
    const startDate = $('#statsStartDate').val();
    const endDate = $('#statsEndDate').val();
  
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
      url: '/stats_filter', 
      type: 'GET',
      dataType: 'json',
      data: {
        start_date: startDate,
        end_date: endDate,
      },
    
      success: function(response) {
        $('#statsInputs').hide();
        updateSalesData(response.top_model);
        updateChart()
        ordersStats(response, startDate, endDate)
        categorySales(response)
        statstopSelling(response.top_selling_products)
  
      }
    });
  
  
  });
  function updateSalesData(newData) {
    document.querySelectorAll(".topSeller").forEach((span) => span.remove());
    let container = document.querySelector(".topSellerContainer");

    // Check if the container exists before proceeding
    if (!container) {
      console.error("Error: .topSellerContainer not found in the DOM.");
      return;
    }
  // Define month names
    const months = {
      "01": "January", "02": "February", "03": "March", "04": "April",
      "05": "May", "06": "June", "07": "July", "08": "August",
      "09": "September", "10": "October", "11": "November", "12": "December"
    };

    // Iterate through new data and append fresh spans
    Object.entries(newData).forEach(([modelName, modelData]) => {
      modelData.forEach(({ month, sales }) => {
        // Extract year and month
        let [year, monthNumber] = month.split("-");
        let monthName = months[monthNumber] ? `${months[monthNumber]} ${year}` : month;

        // Create a new span element
        let newSpan = document.createElement("span");
        newSpan.classList.add("topSeller");
        newSpan.setAttribute("data-model", modelName);
        newSpan.setAttribute("data-month", monthName);
        newSpan.setAttribute("data-sales", sales);
        newSpan.innerHTML = `Model: ${modelName}, Month: ${monthName}, Sales: ${sales}`;

        // Append the new span to the container
        container.appendChild(newSpan);
      });
    });
  }
  

  function updateChart(){
    topModelsChart.destroy()
    const ctx = document.getElementById("top-selling-models").getContext("2d");

    const labelsSet = new Set();
    const salesData = {};

    // Month mapping for proper sorting
    const monthOrder = {
      January: "01",
      February: "02",
      March: "03",
      April: "04",
      May: "05",
      June: "06",
      July: "07",
      August: "08",
      September: "09",
      October: "10",
      November: "11",
      December: "12",
    };

    // Extract data from spans
    document.querySelectorAll(".topSeller").forEach((span) => {
      const model = span.getAttribute("data-model");
      const monthYear = span.getAttribute("data-month"); // e.g., "January 2025"
      const sales = parseFloat(span.getAttribute("data-sales"));

      labelsSet.add(monthYear);

      if (!salesData[model]) {
        salesData[model] = {};
      }
      salesData[model][monthYear] = sales;
    });

    // Sort labels by year and month
    const labels = Array.from(labelsSet).sort((a, b) => {
      const [monthA, yearA] = a.split(" ");
      const [monthB, yearB] = b.split(" ");
      return yearA - yearB || monthOrder[monthA] - monthOrder[monthB];
    });

    const datasets = [];
    const colors = ["#FF5733", "#4285F4", "#34A853", "#FBBC05", "#AB47BC"];

    Object.keys(salesData).forEach((model, index) => {
      datasets.push({
        label: model,
        data: labels.map((month) => salesData[model][month] || 0),
        borderColor: colors[index % colors.length],
        backgroundColor: colors[index % colors.length] + "33",
        fill: false,
        tension: 0.4,
      });
    });

      new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: datasets,
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: true, position: "right" },
          tooltip: {
            callbacks: {
              label: function (tooltipItem) {
                return `$${tooltipItem.raw.toLocaleString()}`; // Ensure $ in tooltip
              },
            },
          },
        },
        scales: {
          yAxes: [{
              ticks: {
                  beginAtZero: true,
                  userCallback: function(value) {
                    return `$${value.toLocaleString()}`; // Ensure $ on Y-axis
 
                  },
              }
          }],
        },
      },
    });
  }
  
  
  
  
  
  function ordersStats(response, startDate, endDate){
    
    $('#maxSellerStatsValue').text(response.max_order_count)
          const maxStatsValue = Number($('#maxSellerStatsValue').text());
            let statsRoundedValue = maxStatsValue / 4;
            $('#firstSellerStatsValue').text(statsRoundedValue * 1);
            $('#secondSellerStatsValue').text(statsRoundedValue * 2);
            $('#thirdSellerStatsValue').text(statsRoundedValue * 3);
            const statsBars = document.querySelectorAll('.stats-bar');
          if (response.max_order_count >= 0 ){
            statsBars.forEach(statsBar => {
              const value = parseInt(statsBar.getAttribute('data-value'), 10);
              let newValue
              let barFill 
              let label 
              let newHref
              const timestamp = new Date().getTime();
  
            
              if (statsBar.querySelector('a').href.includes('new')) {
                newValue = response.new_count;
                barFill = statsBar.querySelector('.bar-fill-statics');
                label = 'New';
                newHref = `/orders-list/?order_status=created&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`;
                statsBar.querySelector('a').href = newHref;
              } else if (statsBar.querySelector('a').href.includes('processing')) {
                newValue = response.processing_count;
                barFill = statsBar.querySelector('.bar-fill-statics-proces');
                label = 'Processing';
                newHref = `/orders-list/?order_status=processing&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`;
                statsBar.querySelector('a').href = newHref;
              } else if (statsBar.querySelector('a').href.includes('completed')) {
                newValue = response.completed_count;
                barFill = statsBar.querySelector('.bar-fill-statics-cmplt');
                label = 'Completed';
                newHref = `/orders-list/?order_status=completed&date_filter=custom&sort=&start_date=${startDate}&end_date=${endDate}&_=${timestamp}`;
                statsBar.querySelector('a').href = newHref;
              }
              statsBar.setAttribute('data-value', newValue);
              statsBar.querySelector('.dolarSet').textContent = newValue;
              const percentage = (newValue / maxStatsValue) * 100;
                if (barFill) {
                  barFill.style.width = `${percentage}%`;
                }
            });
          }else{
            statsBars.forEach(statsBar => {
              const value = parseInt(statsBar.getAttribute('data-value'), 10);
              let newValue;
              let barFill;
              let label;
              barFill = statsBar.querySelector('.bar-fill-seller');
              
            statsBar.setAttribute('data-value', 0);
              statsBar.querySelector('.dolarSet').textContent = 0;
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
  function statstopSelling (products){
    const productsContainer = $('#sellers-top-products');
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
      productsContainer.append('<div class="d-flex justify-content-center align-items-center"><div>No top products present</div></div>');
    }
  }
  
  
  $('#resetStats').on('click', function() {
    $('#orderStartDate').val('');
    $('#orderEndDate').val('');
    const resetStartDate = $('#orderStartDate').val();
    const resetEndDate = $('#orderEndDate').val();
  
    $.ajax({
      url: '/stats_filter', 
      type: 'GET',
      dataType: 'json',
      data: {
        start_date: resetStartDate,
        end_date: resetEndDate,
      },
    
      success: function(response) {
        $('#statsInputs').hide();
        updateSalesData(response.top_model);
        updateChart()
        ordersStats(response, startDate, endDate)
        categorySales(response)
        statstopSelling(response.top_selling_products)
      }
    });
  });
  