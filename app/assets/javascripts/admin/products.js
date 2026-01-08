$(document).ready(function () {
    $('#product_brand_id').on('change', function() {
        var brandId = $(this).val();
        if (brandId === "" || brandId ===undefined ){
            $('#device_div').css('display', 'none');
            $('#product_device_id').val("")
            $('#category_div').css('display', 'none');
            $('#product_category_id').val("")
            $('#product-form').css('display', 'none');
            $('#product_name').val('');
            $('#product_sku').val('');
            $('#product_variant').val('');
        }else{
            $('#no-device').css('display', 'none');
            $.ajax({
                url: '/admin/devices/fetch_devices',
                method: 'GET',
                data: {
                    brand_id: brandId
                },
                success: function (data) {
                    var deviceDropDown = $('#product_device_id');       
                    if (data.length > 0) {
                        $('#device_div').css('display', 'block');
                        $.each(data, function (index, device) {
                            var deviceExists = deviceDropDown.find(`option:contains(${device.name})`).length > 0;
                            if (!deviceExists) {
                                var devices = `<option value="${device.id}">${device.name}</option>`;
                                deviceDropDown.append(devices);
                            }
                        });
                        $('#no-prod').css('display', 'none');
                    } else {
                        $('#device_div').css('display', 'none');
                        $('#no-device').css('display', 'block');

                    }
                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch devices:', error);
                }
            });   
        }         
      });

      $('#product_device_id').on('change', function() {
        var deviceId = $(this).val();

        if (deviceId === "" || deviceId ===undefined ){
            $('#category_div').css('display', 'none');
            $('#product_category_id').val("")
            $('#product-form').css('display', 'none');
            $('#product_name').val('');
            $('#product_sku').val('');
            $('#product_variant').val('');
        }else{
            $.ajax({
                url: '/admin/categories/fetch_categories',
                method: 'GET',
                data: {
                    device_id: deviceId
                },
                success: function (data) {
                    var categoryDropDown = $('#product_category_id');       
                    if (data.length > 0) {
                        $('#category_div').css('display', 'block');
                        $.each(data, function (index, category) {
                            var categoryExists = categoryDropDown.find('option').filter(function() {
                                return $(this).text().trim().toLowerCase() === category.name.trim().toLowerCase();
                            }).length > 0;
                            if (!categoryExists) {
                                var category = `<option value="${category.id}">${category.name}</option>`;
                                categoryDropDown.append(category);
                            }
                        });
                        $('#no-cat').css('display', 'none');
                    } else {
                            $('#no-cat').css('display', 'block')
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch devices:', error);
                }
            });  
        }          
      });
      $('#product_category_id').on('change', function() {
        var categoryId = $(this).val();
        if (categoryId === "" || categoryId ===undefined ){

            $('#product-form').css('display', 'none');
            $('#product_name').val('');
            $('#product_sku').val('');
            $('#product_variant').val('');
        }else{
            $('#product-form').css('display', 'block');

        }

      })
    });

