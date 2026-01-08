$(document).on('click', '#close-stats', function () {
    $('#brandStatsModal').modal('hide');
 });
$(document).on('click', '#brand-stats', function (event) {
    event.preventDefault(); // Prevent default behavior of the link

    const dataId = $(this).data('id');
    const brand_sales = $(this).data('sales');
    $('#brandStatsModal').modal('show');
    
    $.ajax({
        url: '/admin/brand_stats_devices', 
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
                                <span id="model-stats" class="model-stats" data-brand="${response.brand_name}" data-device="${device.name}">${device.name}</span>
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

            $('#brandStatsModal .modal-body').html(modalContent);
            barsChartStats('deviceBarBrand', brand_sales)
            barsChartStats('deviceBarDevice', response.brand_sales.length > 0 ?  response.brand_sales[0].sales : 0)
        },
        error: function (xhr, status, error) {
            console.error('AJAX Error:', error);
            $('#brandStatsModal .modal-body').html('<p>Error loading data. Please try again.</p>');
        }
    });
});

$(document).on('click', '#model-stats', function (event) {
    event.preventDefault();

    const name = $(this).data('device');
    const brandName = $(this).data('brand');
    $('.model-stats').css('text-decoration', 'none');
    $(this).css('text-decoration', 'underline');
    
    $.ajax({
        url: '/admin/brand_stats_models', 
        type: 'GET',                
        data: { name: name, brand_name: brandName },      
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
                                <span id="products-stats" class="products-stats" data-brand="${response.brand_id}" data-device=${response.device_id} data-model = "${model.name}">${model.name}</span>
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
            $('#brandStatsModal .modal-body').append(modalContent);
            barsChartStats('deviceBarModels', response.models_sales.length > 0 ?  response.models_sales[0].sales : 0)

        },
        error: function (xhr, status, error) {
            console.error('AJAX Error:', error);
            $('#brandStatsModal .modal-body').html('<p>Error loading data. Please try again.</p>');
        }
    });
});

$(document).on('click', '#products-stats', function (event) {
    event.preventDefault();

    const name = $(this).data('model');
    const brandId = $(this).data('brand');
    const deviceId = $(this).data('device');
    
    $('.products-stats').css('text-decoration', 'none');
    $(this).css('text-decoration', 'underline');
    
    $.ajax({
        url: '/admin/brand_stats_products', 
        type: 'GET',                
        data: { name: name, brand_id: brandId, device_id: deviceId },      
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
                    <a href ="/admin/products/${model.id}/">
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
            $('#brandStatsModal .modal-body').append(modalContent);
            barsChartStats('deviceBarProducts', response.models_sales.length > 0 ?  response.models_sales[0].sales : 0)
        },
        error: function (xhr, status, error) {
            console.error('AJAX Error:', error);
            $('#brandStatsModal .modal-body').html('<p>Error loading data. Please try again.</p>');
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
 