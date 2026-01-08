let brandText = $('#BrandBtn').text();
let deviceText = $('#deviceBtn').text();
let categoryText = $('#modelBtn').text();


let brandFilter = ''  
let deviceFilter = ''
let categoryFilter = ''






$('#brandsdropdown').on('click', 'li', function (event) {
    let brand = $(this).data('brand');
    let text = $(this).text();
    if (text === brandFilter) {
        return true;
    }

    if (brand === '') {
        $('#BrandBtn').text('Brand');
    } else {
        $('#BrandBtn').text(text);
    }

    brandText = text;
    brandFilter = brand;
    sendRequest();
});

$('#deviceDropdown').on('click', 'li', function (event) {
    let device = $(this).data('device'); 
    let text = $(this).text();    

    if (text === deviceText) {
        return true;
    }

    

    if (device === '') {
        $('#deviceBtn').text('Device');
    } else {
        $('#deviceBtn').text(text);
    }

    deviceText = text;
    deviceFilter = device;                     

    sendRequest();
    
});
$('#modelDropdown').on('click', 'li', function (event) {
    let category = $(this).data('model'); 
    let text = $(this).text();    

    if (text === categoryText) {
        return true;
    }

    

    if (category === '') {
        $('#modelBtn').text('Model');
    } else {
        $('#modelBtn').text(text);
    }

    categoryText = text;
    categoryFilter = category;                     

    sendRequest();
    
});


$('#apply-filter-product').click(function(){
    let  brandFilter = $('#product-brand').val()
    let  deviceFilter = $('#product-device').val()
    let  categoryFilter = $('#product-model').val()   
    sendRequest(brandFilter, deviceFilter, categoryFilter)
  });


function sendRequest(brandFilter, deviceFilter, categoryFilter) {

    $.ajax({
        url: '/product-inventories', 
        type: 'GET',
        data: {
            brand: brandFilter,
            device: deviceFilter,
            category: categoryFilter,
            
        },
        dataType: 'script',
        success: function (response) {
        },
        error: function (xhr, status, error) {
            console.log('Error: ' + error);
        }
    });
}

$('#resetInventories').click(function(){
    $('#product-brand').val('');
    $('#product-device').val('');
    $('#product-model').val('');
    let  brandFilter = $('#product-brand').val();
    let  deviceFilter = $('#product-device').val();
    let  categoryFilter = $('#product-model').val();
   
    sendRequest(brandFilter, deviceFilter, categoryFilter)

})

