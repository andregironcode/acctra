$(document).ready(function () {
    $('#category_brand_id').on('change', function() {
        var brandId = $(this).val();
        if (brandId === "" || brandId ===undefined ){
            $('#device_div').css('display', 'none');
            $('#product_device_id').val("")
            $('#category_div').css('display', 'none');
            $('#product_category_id').val("")
        }else{
            $.ajax({
                url: '/admin/devices/fetch_devices',
                method: 'GET',
                data: {
                    brand_id: brandId
                },
                success: function (data) {
                    var deviceDropDown = $('#category_device_id');       
                    if (data.length > 0) {
                        $('#device_div').css('display', 'block');
                        $.each(data, function (index, device) {
                            var deviceExists = deviceDropDown.find(`option:contains(${device.name})`).length > 0;
                            if (!deviceExists) {
                                var devices = `<option value="${device.id}">${device.name}</option>`;
                                deviceDropDown.append(devices);
                            }
                        });
                        $('#no-device').css('display', 'none');
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

      $('#category_device_id').on('change', function() {
        var deviceId = $(this).val();

        if (deviceId === "" || deviceId ===undefined ){
            $('#new-category-form').css('display', 'none')

          
        }else{
            $('#new-category-form').css('display', 'block')
             
        }          
      });
    
    });

