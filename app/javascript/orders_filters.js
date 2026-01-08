let dateText = $('#dateBtn').text();
let orderTypeText = $('#orderTypeBtn').text();
let sortText = $('#sortBtn').text();
let orderStatus = ''  
let dateFilter = ''
let sortType = ''
let startDate = $('#startDate').val();
let endDate = $('#endDate').val();





$('#sortDropdown').on('click', 'li', function (event) {
    let sort = $(this).data('sort');
    sortType = sort
    let text = $(this).text();
    if (text === sort) {
        return true;
    }

    if (sort === '') {
        $('#sortBtn').text('Filter By');
    } else {
        $('#sortBtn').text(text);
    }

    sortText = text;
    sendAjaxRequest();
});

$('#dateDropdown').on('click', 'li', function (event) {
    let date = $(this).data('date-type'); 
    dateFilter = date;                     
    let text = $(this).text();    
    if (date === 'custom') {
        $('#customDateInputs').show();     
    } else {
        $('#customDateInputs').hide();     
    }
    if (text === dateText) {
        return true;
    }

    if (date === 'custom') {
        $('#dateBtn').text('Custom Date');
    } else {
        $('#dateBtn').text(text);
    }

    if (date === '') {
        $('#dateBtn').text('Date');
    } else {
        $('#dateBtn').text(text);
    }

    dateText = text;
    if (date !== 'custom'){
        sendAjaxRequest();
    }
});

$('#applyCustomDate').on('click', function() {
    const startDate = $('#orderStartDate').val();
    const endDate = $('#orderEndDate').val();
   

    if (!startDate || !endDate) {
        toastr.error('Please select both start and end dates.');
        return;
    }

    if (new Date(endDate) < new Date(startDate)) {
        toastr.error('End date cannot be earlier than start date.');
        return;
    }

    sendAjaxRequest();
    $('#orderStartDate').val('');
    $('#orderEndDate').val('');
    $('#customDateInputs').hide();  
});


$('#cancelBtn').on('click', function() {
    $('#startDate').val('');
        $('#endDate').val('');
    $('#customDateInputs').hide();  
});


$('#orderType').on('click', 'li', function (event) {
    let order= $(this).data('order-type');
    orderStatus = order
    let text = $(this).text();
    if (text === orderTypeText) {
        return true;
    }

    if (order === '') {
        $('#orderTypeBtn').text('Order Status');
        orderStatus = ''

    } else {
        $('#orderTypeBtn').text(text);
    }

    orderTypeText = text;
    sendAjaxRequest();
});

$('#apply-filter').click(function(){
  let  orderStatus = $('#order-status').val()
  let  sortType = $('#order-filter-by').val()
  let  startDate = $('#orderStartDate').val()
  let  endDate = $('#orderEndDate').val()
  let  dateFilter = ''
    if (startDate !== ''){
        dateFilter ="custom"
    }
    sendAjaxRequest (orderStatus, dateFilter, sortType, startDate, endDate)
});

function sendAjaxRequest (orderStatus, dateFilter, sortType, startDate, endDate){

    $.ajax({
        url: '/orders-list', 
        type: 'GET',
        data: {
            order_status: orderStatus,
            date_filter: dateFilter,
            sort: sortType,
            start_date: startDate,
            end_date: endDate,
        },
        dataType: 'script',
        success: function (response) {
        },
        error: function (xhr, status, error) {
            console.log('Error: ' + error);
        }
    });
}
 
$('#orderReset').click(function(){
    $('#order-status').val('')
     $('#order-filter-by').val('')
     $('#orderStartDate').val('')
     $('#orderEndDate').val('')
    orderStatus=''
    dateFilter = ''
    sortType = ''
    startDate =''
    endDate = ''
    sendAjaxRequest (orderStatus, dateFilter, sortType, startDate, endDate)
})

const $searchForm = $('#search_form');
const $searchInput = $('#search_input');
$searchForm.on('submit', function(event) {
  event.preventDefault(); 
  const searchValue = $searchInput.val().trim();
 
    $.ajax({
      url: $searchForm.attr('action'),
      type: 'GET', 
      dataType: 'script',

      data: { 
        
        order_status: orderStatus,
        date_filter: dateFilter,
        sort: sortType,
        search: searchValue, 
        start_date: startDate,
        end_date: endDate,
     },
      success: function(data) {
        
      },
      error: function(xhr, status, error) {
        console.error('AJAX request failed: ', error);
      }
    });
});