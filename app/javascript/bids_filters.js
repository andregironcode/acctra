// let dateText = $('#dateBtn').text();
// let orderStatus = ''  
// let dateFilter = ''
// let sortType = ''


let bidStatusFilter = $('#bidStatus').text();
let sortBidText = $('#bidSortDropdown').text();
let BidDateFilter = ''
let BidSortType = ''
let BidStatus = ''  



$('#bidSortDropdown').on('click', 'li', function (event) {
    let sort = $(this).data('sort');
    BidSortType = sort
    let text = $(this).text();
    if (text === sort) {
        return true;
    }

    if (sort === '') {
        $('#sortBtnBid').text('Filter By');
    } else {
        $('#sortBtnBid').text(text);
    }

    sortBidText = text;
    sendAjaxBids();
});

$('#bidStatus').on('click', 'li', function (event) {
    let bid= $(this).data('bid-status');
    BidStatus = bid
    let text = $(this).text();
    if (text === orderTypeText) {
        return true;
    }

    if (bid === '') {
        $('#bidStatusBtn').text('Bids Status');
        BidStatus = ''

    } else {
        $('#bidStatusBtn').text(text);
    }

    bidStatusFilter = text;
    sendAjaxBids();
});

$('#applyCustomDateBids').on('click', function() {
    const BidstartDate = $('#bidStartDate').val();
    const BidendDate = $('#bidEndDate').val();
    if (!BidstartDate || !BidendDate) {
        toastr.error('Please select both start and end dates.');
        return;
    }
    
    if (new Date(BidendDate) < new Date(BidstartDate)) {
        toastr.error('End date cannot be earlier than start date.');
        return;
    }

    sendAjaxBids();
    $('#bidStartDate').val('');
    $('#bidEndDate').val('');
});

$('#cancelBtnBids').on('click', function() {
    $('#bidStartDate').val('');
    $('#bidEndDate').val('');
});


$('#buyer-bid-apply-filter').click(function(){
    let  BidStatus = $('#buyer-bids-status').val()
    let  BidSortType = $('#buyer-bid-filter-by').val()
    let  BidstartDate = $('#buyerBidStartDate').val()
    let  BidsEndDate = $('#buyeBidEndDate').val()
    sendAjaxBids(BidStatus, BidSortType, BidstartDate, BidsEndDate)
});
function sendAjaxBids(BidStatus, BidSortType, BidstartDate, BidsEndDate)
{
   

    $.ajax({
        url: '/my-bids', 
        type: 'GET',
        data: {
            bids_status: BidStatus,
            sort: BidSortType,
            start_date: BidstartDate,
            end_date: BidsEndDate,
           
        },
        dataType: 'script',
        success: function (response) {
        },
        error: function (xhr, status, error) {
            console.log('Error: ' + error);
            console.log(xhr.responseText); // Debugging the response content

        }
    });
}
$('#resetBidFilter').click(function(){
    $('#dateBtn').text('Date');
    $('#bidStatusBtn').text('Bids Status');
    $('#sortBtnBid').text('Filter By');
    BidStatus=''
    dateFilter = ''
    BidSortType = ''
    sendAjaxBids();

})

//Sellers bids filters



let SellerBidStatusFilter = $('#bidStatus').text();
let SellerSortBidText = $('#bidSortDropdown').text();
let SellerBidSortType = ''
let SellerBidStatus = ''  



$('#SellerBidSortDropdown').on('click', 'li', function (event) {
    let sort = $(this).data('sort');
    SellerBidSortType = sort
    let text = $(this).text();
    if (text === sort) {
        return true;
    }

    if (sort === '') {
        $('#sortBtnBid').text('Filter By');
    } else {
        $('#sortBtnBid').text(text);
    }

    sortBidText = text;
    sendSellerAjaxBids();
});

$('#SellerbidStatus').on('click', 'li', function (event) {
    let bid= $(this).data('bid-status');
    SellerBidStatus = bid
    let text = $(this).text();
    if (text === orderTypeText) {
        return true;
    }

    if (bid === '') {
        $('#SellerBidStatusBtn').text('Bids Status');
        SellerBidStatus = ''

    } else {
        $('#SellerBidStatusBtn').text(text);
    }

    bidStatusFilter = text;
    sendSellerAjaxBids();
});

$('#SellerApplyCustomDateBids').on('click', function() {
    const BidstartDate = $('#SellerStartDate').val();
    const BidendDate = $('#SellerEndDate').val();
    if (!BidstartDate || !BidendDate) {
        toastr.error('Please select both start and end dates.');
        return;
    }
    
    if (new Date(BidendDate) < new Date(BidstartDate)) {
        toastr.error('End date cannot be earlier than start date.');
        return;
    }

    sendSellerAjaxBids();
    $('#bidStartDate').val('');
    $('#bidEndDate').val('');
});

$('#SellerCancelBtnBids').on('click', function() {
    $('#SellerStartDate').val('');
    $('#SellerEndDate').val('');
});


$('#Bid-apply-filter').click(function(){
    let  BidStatus = $('#bids-status').val()
    let  BidSortType = $('#bid-filter-by').val()
    let  BidstartDate = $('#bidStartDate').val()
    let  BidsEndDate = $('#bidEndDate').val()
    sendSellerAjaxBids(BidStatus, BidSortType, BidstartDate, BidsEndDate)
});

function sendSellerAjaxBids(BidStatus, BidSortType, BidstartDate, BidsEndDate){
  
    $.ajax({
        url: '/bids', 
        type: 'GET',
        data: {
            bids_status: BidStatus,
            sort: BidSortType,
            start_date: BidstartDate,
            end_date: BidsEndDate,
           
        },
        dataType: 'script',
        success: function (response) {
        },
        error: function (xhr, status, error) {
            console.log('Error: ' + error);
            console.log(xhr.responseText);

        }
    });
}
$('#SellerResetBidFilter').click(function(){
    BidStatus = $('#bids-status').val('')
    BidSortType = $('#bid-filter-by').val('')
    BidstartDate = $('#bidStartDate').val('')
    BidsEndDate = $('#orderEndDate').val('')
   
    sendSellerAjaxBids(BidStatus, BidSortType, BidstartDate, BidsEndDate)

})