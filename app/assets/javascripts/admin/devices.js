$(document).ready(function () {
    $('#device_brand_id').on('change', function() {
        
        var brandId = $(this).val();
        if (brandId === "" || brandId ===undefined ){
            $('#device-form').css('display', 'none');
        }else {
            $('#device-form').css('display', 'block');
        }
    });
});