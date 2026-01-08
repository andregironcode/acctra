const countries ={
    "AF": "Afghanistan",
    "AL": "Albania",
    "DZ": "Algeria",
    "AD": "Andorra",
    "AO": "Angola",
    "AR": "Argentina",
    "AM": "Armenia",
    "AU": "Australia",
    "AT": "Austria",
    "AZ": "Azerbaijan",
    "BS": "Bahamas",
    "BH": "Bahrain",
    "BD": "Bangladesh",
    "BB": "Barbados",
    "BY": "Belarus",
    "BE": "Belgium",
    "BZ": "Belize",
    "BJ": "Benin",
    "BT": "Bhutan",
    "BO": "Bolivia",
    "BA": "Bosnia and Herzegovina",
    "BW": "Botswana",
    "BR": "Brazil",
    "BN": "Brunei",
    "BG": "Bulgaria",
    "BF": "Burkina Faso",
    "BI": "Burundi",
    "KH": "Cambodia",
    "CM": "Cameroon",
    "CA": "Canada",
    "CV": "Cape Verde",
    "CF": "Central African Republic",
    "TD": "Chad",
    "CL": "Chile",
    "CN": "China",
    "CO": "Colombia",
    "KM": "Comoros",
    "CG": "Congo",
    "CD": "Democratic Republic of the Congo",
    "CR": "Costa Rica",
    "CI": "Côte d'Ivoire",
    "HR": "Croatia",
    "CU": "Cuba",
    "CY": "Cyprus",
    "CZ": "Czech Republic",
    "DK": "Denmark",
    "DJ": "Djibouti",
    "DO": "Dominican Republic",
    "EC": "Ecuador",
    "EG": "Egypt",
    "SV": "El Salvador",
    "GQ": "Equatorial Guinea",
    "ER": "Eritrea",
    "EE": "Estonia",
    "ET": "Ethiopia",
    "FJ": "Fiji",
    "FI": "Finland",
    "FR": "France",
    "GA": "Gabon",
    "GM": "Gambia",
    "GE": "Georgia",
    "DE": "Germany",
    "GH": "Ghana",
    "GR": "Greece",
    "GT": "Guatemala",
    "GN": "Guinea",
    "GY": "Guyana",
    "HT": "Haiti",
    "HN": "Honduras",
    "HU": "Hungary",
    "IS": "Iceland",
    "IN": "India",
    "ID": "Indonesia",
    "IR": "Iran",
    "IQ": "Iraq",
    "IE": "Ireland",
    "IL": "Israel",
    "IT": "Italy",
    "JM": "Jamaica",
    "JP": "Japan",
    "JO": "Jordan",
    "KZ": "Kazakhstan",
    "KE": "Kenya",
    "KR": "South Korea",
    "KW": "Kuwait",
    "LA": "Laos",
    "LV": "Latvia",
    "LB": "Lebanon",
    "LY": "Libya",
    "LT": "Lithuania",
    "LU": "Luxembourg",
    "MG": "Madagascar",
    "MW": "Malawi",
    "MY": "Malaysia",
    "MV": "Maldives",
    "ML": "Mali",
    "MT": "Malta",
    "MX": "Mexico",
    "MC": "Monaco",
    "MN": "Mongolia",
    "ME": "Montenegro",
    "MA": "Morocco",
    "MZ": "Mozambique",
    "MM": "Myanmar",
    "NA": "Namibia",
    "NP": "Nepal",
    "NL": "Netherlands",
    "NZ": "New Zealand",
    "NI": "Nicaragua",
    "NE": "Niger",
    "NG": "Nigeria",
    "NO": "Norway",
    "OM": "Oman",
    "PK": "Pakistan",
    "PA": "Panama",
    "PY": "Paraguay",
    "PE": "Peru",
    "PH": "Philippines",
    "PL": "Poland",
    "PT": "Portugal",
    "QA": "Qatar",
    "RO": "Romania",
    "RU": "Russia",
    "RW": "Rwanda",
    "SA": "Saudi Arabia",
    "SN": "Senegal",
    "RS": "Serbia",
    "SG": "Singapore",
    "SK": "Slovakia",
    "SI": "Slovenia",
    "SO": "Somalia",
    "ZA": "South Africa",
    "ES": "Spain",
    "LK": "Sri Lanka",
    "SD": "Sudan",
    "SE": "Sweden",
    "CH": "Switzerland",
    "SY": "Syria",
    "TW": "Taiwan",
    "TJ": "Tajikistan",
    "TZ": "Tanzania",
    "TH": "Thailand",
    "TG": "Togo",
    "TN": "Tunisia",
    "TR": "Turkey",
    "TM": "Turkmenistan",
    "UG": "Uganda",
    "UA": "Ukraine",
    "AE": "United Arab Emirates",
    "GB": "United Kingdom",
    "US": "United States",
    "UY": "Uruguay",
    "UZ": "Uzbekistan",
    "VE": "Venezuela",
    "VN": "Vietnam",
    "YE": "Yemen",
    "ZM": "Zambia",
    "ZW": "Zimbabwe",
    "Europe": "Europe"
  }
  
$(document).ready(function () {
    $('#brand_select').on('change', function() {
        var brandId = $(this).val();
        if (brandId === "" || brandId ===undefined ){
            $('#device_div').css('display', 'none');

        }else{
            $.ajax({
                url: '/sellers-fetch-devices',
                method: 'GET',
                data: {
                    brand_id: brandId
                },
                success: function (data) {
                    $('#category_div').addClass('d-none').removeClass('d-block');
                    $('#country_div').addClass('d-none').removeClass('d-block');
                    $('#products_div').addClass('d-none').removeClass('d-block');
                    $('#stock-price').addClass('d-none').removeClass('d-block');



                    var deviceDropDown = $('#inventory_device');
                    deviceDropDown.html('')       
                    if (data.length > 0) {
                        $('#device_div').addClass('d-block').removeClass('d-none');
                        var selectDevice = `<option>Select Device</option>`;
                        deviceDropDown.append(selectDevice)
                        $.each(data, function (index, device) {
                            var deviceExists = deviceDropDown.find(`option:contains(${device.name})`).length > 0;
                            if (!deviceExists) {

                                var devices = `<option value="${device.id}">${device.name}</option>`;
                                deviceDropDown.append(devices);
                            }
                        });
                        $('#no-device').css('display', 'none');
                    } else {
                        
                        $('#device_div').addClass('d-none').removeClass('d-block');
                        $('#no-device').css('display', 'block');  

                    }
                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch devices:', error);
                }
            });   
        }         
      });
      $('#inventory_device').on('change', function() {
        var deviceId = $(this).val();

        if (deviceId === "" || deviceId ===undefined ){
            $('#category_div').css('display', 'none');
        }else{
            $('#products_div').addClass('d-none').removeClass('d-block');
            $('#stock-price').addClass('d-none').removeClass('d-block');
            $.ajax({
                url: '/sellers-fetch-categories',
                method: 'GET',
                data: {
                    device_id: deviceId
                },
                success: function (data) {
                    var categoryDropDown = $('#inventory_category');
                    categoryDropDown.html('')
                    var selectCategory = `<option>Select Model</option>`;
                    categoryDropDown.append(selectCategory)
                    if (data.length > 0) {
                        $('#category_div').addClass('d-block').removeClass('d-none');
                        $.each(data, function (index, category) {
                            var categoryExists = categoryDropDown.find(`option[value='${category.id}']`).length > 0;
                            if (!categoryExists) {
                                var category = `<option value="${category.id}">${category.name}</option>`;
                                categoryDropDown.append(category);
                            }
                        });
                        $('#no-cat').css('display', 'none');
                    } else {      
                        $('#no-cat').css('display', 'block');
                        $('#category_div').addClass('d-none').removeClass('d-block');
                        $('#products_div').addClass('d-none').removeClass('d-block');


                    }
                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch devices:', error);
                }
            });  
        }          
      });


      $('#inventory_category').on('change', function() {
        var categoryId = $(this).val();
        if (categoryId === "" || categoryId ===undefined ){
            $('#products_div').addClass('d-none').removeClass('d-block');
            $('#product-form').css('display', 'none');
            $('#product_name').val('');
            $('#product_sku').val('');
            $('#product_variant').val('');
        }else{
            $('#category_div').addClass('d-block').removeClass('d-none');
            const deviceDiv = $('#category-div');
            deviceDiv.addClass('d-none').removeClass('d-flex');
            $('#products_div').addClass('d-none').removeClass('d-block');
            $.ajax({
                url: '/products/fetch_products_countries',
                method: 'GET',
                data: {
                    category_id: categoryId
                },
                success: function (data) {
                    var categoryDropDown = $('#inventory_country');  
                    categoryDropDown.html('');
                    var selectProduct = `<option>Select Country</option>`;
                    categoryDropDown.append(selectProduct);

                    if (data.length > 0) {
                        $('#country_div').addClass('d-block').removeClass('d-none');
                        
                        $.each(data, function (index, product) {
                            var categoryExists = categoryDropDown.find(`option:contains(${countries[product.country]})`).length > 0;
                            if (!categoryExists) {
                                var category = `<option data-category="${product.category_id}" value="${product.country}">${countries[product.country]}</option>`;
                                categoryDropDown.append(category);
                            }
                        });
                        $('#no-prod').css('display', 'none');
                    } else {
                        if (categoryDropDown.children().length === 0) {
                            $('#no-country').text('No Country Found in this brand');
                            $('#no-country').css('display', 'block');
                        } else {
                            $('#no-country').css('display', 'none');
                        }
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch products:', error);
                }
            });  

        }

      });


      $('#inventory_country').on('change', function() {
        var selectedOption = $(this).find('option:selected'); // Get selected option
        var country = selectedOption.val(); // Get country code
        var categoryId = selectedOption.data('category'); 
        if (country === "" || categoryId ===undefined ){
            $('#products_div').addClass('d-none').removeClass('d-block');
            $('#product-form').css('display', 'none');
            $('#product_name').val('');
            $('#product_sku').val('');
            $('#product_variant').val('');
        }else{
            $('#country_div').addClass('d-block').removeClass('d-none');
            const productDiv = $('#products_div');
            productDiv.addClass('d-none').removeClass('d-flex');
            $('#products_div').addClass('d-none').removeClass('d-block');
            $.ajax({
                url: '/products/fetch_products',
                method: 'GET',
                data: {
                    country: country,
                    category_id: categoryId
                },
                success: function (data) {
                    var categoryDropDown = $('#inventory_products');  
                    categoryDropDown.html('');
                    var selectProduct = `<option>Select Product</option>`;
                    categoryDropDown.append(selectProduct);

                    if (data.length > 0) {

                        $('#products_div').addClass('d-block').removeClass('d-none');
                        
                        $.each(data, function (index, product) {
                            var categoryExists = categoryDropDown.find(`option:contains(${product.sku})`).length > 0;
                            if (!categoryExists) {
                                var category = `<option value="${product.id}">${product.name}-${product.variant} (${product.sku})</option>`;
                                categoryDropDown.append(category);
                            }
                        });
                        $('#no-prod').css('display', 'none');
                    } else {
                        if (categoryDropDown.children().length === 0) {
                            $('#no-prod').text('No Product Found in this country');
                            $('#no-prod').css('display', 'block');
                        } else {
                            $('#no-prod').css('display', 'none');
                        }
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch products:', error);
                }
            });  

        }

      });
      $('#inventory_products').on('change', function(){
        $('#stock-price').addClass('d-block').removeClass('d-none');

      })
    });
    
    function getDevices (brandId, event){
        document.querySelectorAll('.brandLanding').forEach(function (element) {
            element.classList.remove('brandActive');
        });
        event.target.classList.add("brandActive");
        
        if (brandId === "" || brandId ===undefined ){
            return
        }else{
            const deviceDiv = $('#device-div');
            deviceDiv.addClass('d-flex').removeClass('d-none');
            const categoryDiv = $('#category-div');
            categoryDiv.addClass('d-none').removeClass('d-flex');
            const productsTable = $('#products-table');
            productsTable.addClass('d-none').removeClass('d-flex');
            const productsDiv = $('#products-div');
            productsDiv.addClass('d-none').removeClass('d-flex');

            $.ajax({
                url: '/fetch-devices',
                method: 'GET',
                data: {
                    brand_id: brandId
                },

                success: function (data) {

                    const scrollDiv = deviceDiv.find('.brandNameScroll');
                        scrollDiv.empty();
                    if (data.length > 0) {
                        data.forEach(function (device) {
                            const deviceElement = `<div class="productLanding mt-3" data-device-id=${device.id}" onclick="getCategories(event)" >${device.name}</div>`;
                            scrollDiv.append(deviceElement);
                        });
                    } else {
                        scrollDiv.append('<div class="text-muted mt-3">No devices found</div>');
                    }

                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch devices:', error);
                }
            });   
        }         
    }

    function getCategories ( event){
        const clickedElement = event.target;

        const deviceId = clickedElement.getAttribute("data-device-id");
            document.querySelectorAll('.productLanding').forEach(function (element) {
            element.classList.remove('productActive');
        });
        event.target.classList.add("productActive");
        
        if (deviceId === "" || deviceId ===undefined ){
            return
        }else{
            const categoryDiv = $('#category-div');
            categoryDiv.addClass('d-flex').removeClass('d-none');
            const productsTable = $('#products-table');
            productsTable.addClass('d-none').removeClass('d-flex');
            const productsDiv = $('#products-div');
            productsDiv.addClass('d-none').removeClass('d-flex');

            $.ajax({
                url: '/fetch-categories',
                method: 'GET',
                data: {
                    device_id: deviceId
                },

                success: function (data) {

                    const scrollDiv = categoryDiv.find('.brandNameScroll');
                        scrollDiv.empty();
                    if (data.length > 0) {
                        data.forEach(function (category) {
                            const deviceElement = `<div class=" categoryLanding mt-3" data-category-id=${category.id}" onclick="getProducts(event)">${category.name}</div>`;
                            scrollDiv.append(deviceElement);
                        });
                    } else {
                        scrollDiv.append('<div class="text-muted mt-3">No devices found</div>');
                    }

                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch devices:', error);
                }
            });   
        }         
    }

    function getInventories (event){
        const clickedElement = event.currentTarget;

        const productName = clickedElement.getAttribute("data-product-name");
            document.querySelectorAll('.productNameLanding, .productNameHeading, .productNameStockFnt').forEach(function (element) {
            element.classList.remove('productActive', 'font-weight-bold');
        });
        clickedElement.classList.add("productActive");
        clickedElement.querySelectorAll(".productNameHeading, .productNameStockFnt").forEach(child => {
            child.classList.add("productActive" ,"font-weight-bold");
        });
        if (productName === "" || productName ===undefined ){
            return
        }else{
            const productDiv = $('#products-table');
            productDiv.addClass('d-flex').removeClass('d-none');

            $.ajax({
                url: '/fetch-inventories',
                method: 'GET',
                data: {
                    product_name: productName
                },

                success: function (data) {
                    const tbody = $('#products-table-body');
                        tbody.empty();
                        if (data.length > 0) {
                            data.forEach(function (product) {
                                const row = $('<tr></tr>');
                                row.append(`
                                    <td>
                                      <div class="d-flex align-items-center justify-content-center"> 
                                        ${
                                          product.country.toLowerCase() === "europe"
                                            ? `<img src="${window.europeImagePath}" width="35" height="35" alt="Europe">`
                                            : `<div class="flag flag-icon flag-icon-${product.country.toLowerCase()} flag-icon-squared"></div>`
                                        }
                                      </div>
                                    </td>
                                  `);
                                  
                                row.append('<td class="text-center">' + product.name + '</td>');
                                row.append('<td class="text-center">' + product.sku + '</td>'); 
                                row.append('<td class="text-center">' + product.variant + '</td>'); 
                                row.append(`<td class="text-center" id="${product.inventory_id}-price">$` + Math.round(product.price).toLocaleString('en-US') + '</td>'); 
                                row.append(`<td class="text-center" id="${product.inventory_id}-stock">` + product.stock + `</td>`);  
                                row.append(`<td class="text-center">` +  `${product.model_number == null ? "-" : product.model_number}`+ `</td>`);        

                                row.append(`
                                    <td class="text-center" id="${product.inventory_id}-quantity-cart">
                                        <span class="cursor-pointer" onclick="changeQuantity(${product.inventory_id}, -1, ${product.stock})">
                                          
                                        <svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <path d="M8 10H10H14V8H10H8H4V10H8ZM2 18C1.45 18 0.979167 17.8042 0.5875 17.4125C0.195833 17.0208 0 16.55 0 16V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H16C16.55 0 17.0208 0.195833 17.4125 0.5875C17.8042 0.979167 18 1.45 18 2V16C18 16.55 17.8042 17.0208 17.4125 17.4125C17.0208 17.8042 16.55 18 16 18H2Z" fill="#979797"/>
                                        </svg>

                                        </span>
                                        <input type="number" id="${product.inventory_id}-quantity" class="quantity-input" value="1" min="0" step="1" oninput="validateQuantity(${product.inventory_id})" onchange="changeQuantityInput(${product.inventory_id}, ${product.stock}, event)" >
                                        <span class="cursor-pointer" onclick="changeQuantity(${product.inventory_id}, 1, ${product.stock} )">
                                        <svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M8 14H10V10H14V8H10V4H8V8H4V10H8V14ZM2 18C1.45 18 0.979167 17.8042 0.5875 17.4125C0.195833 17.0208 0 16.55 0 16V2C0 1.45 0.195833 0.979167 0.5875 0.5875C0.979167 0.195833 1.45 0 2 0H16C16.55 0 17.0208 0.195833 17.4125 0.5875C17.8042 0.979167 18 1.45 18 2V16C18 16.55 17.8042 17.0208 17.4125 17.4125C17.0208 17.8042 16.55 18 16 18H2Z" fill="#979797"/>
                                            </svg>
                                        </span>
                                    </td>
                                `);                                row.append(`<td class="d-flex justify-content-center"clickP>
                                    <div class="d-flex rounded bckcolor cursor-pointer">
                                        <span class="p-2 font-weight-bold  border-top-0 border-left-0 border-bottom-0 rounded-0 borderRight"" onclick="cart(${product.id}, ${product.inventory_id}, this, ${product.stock} )">
                                        Add to Cart
                                        </span>
                    <span class="p-2 font-weight-bold border-top-0 border-left-0 border-bottom-0 rounded-0 borderRight position-relative" onclick="clickPopUp(${product.inventory_id}, ${product.id}, '${product.name.replace(/'/g, "\\'")}', '${product.sku}', '${product.price}', '${product.variant}', ${product.stock}, '${product.model_number}')">
                                            Apply Bid </span>
                                        </div>
                                        </span>
                                        
                                    </div>
                                    </td>`);
                                tbody.append(row);
                            });
                        } else {
                            tbody.append('<tr><td colspan="3" class="text-muted text-center">No devices found</td></tr>');
                        }
                        window.scrollTo({
                            top: document.body.scrollHeight, 
                            behavior: "smooth"  // Smooth scrolling effect
                        });

                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch devices:', error);
                }
            });   
        }         
    }


    function getProducts ( event){
        const clickedElement = event.target;

        const categoryId = clickedElement.getAttribute("data-category-id");
            document.querySelectorAll('.categoryLanding').forEach(function (element) {
            element.classList.remove('productActive');
        });
        event.target.classList.add("productActive");
        
        if (categoryId === "" || categoryId ===undefined ){
            return
        }else{
            const productDiv = $('#products-div');
            productDiv.addClass('d-flex').removeClass('d-none');
            

            $.ajax({
                url: '/fetch-products',
                method: 'GET',
                data: {
                    category_id: categoryId
                },

                success: function (data) {
                    const scrollDiv = productDiv.find('.brandNameScroll');
                    scrollDiv.empty();
                    if (data.length > 0) {
                        data.forEach(function (product) {
                            const uniqueCountries = [...new Set(product.inventories.map(inv => inv.country))];
                            const countryListHTML = uniqueCountries.map(country => `<div>${country}</div>`).join("");
                            const priceListHTML = product.inventories.map(inv => `<div>$${Number(inv.price)}</div>`).join("");
                            const stockListHTML = product.inventories.map(inv => `<div>${inv.stock}</div>`).join("");
                            const variant = product.inventories.map(inv => `<div>${inv.variant}</div>`).join("");

                            const productElement = `
                            
                                <div class="mt-3 productNameLanding" data-product-name='${product.name}' onclick="getInventories(event)">
                                        <div class="productNameHeading">
                                        ${product.name}
                                        </div>
                                        <div class="d-flex flex-row justify-content-between productNameStockFnt">
                                            <div class="d-flex flex-column">
                                                <div>
                                                    Country
                                                </div>
                                                ${countryListHTML}

                                            
                                            </div>
                                            <div class="d-flex flex-column">
                                                <div>
                                                    Variant
                                                </div>
                                                ${variant}

                                            
                                            </div>
                                            <div class="d-flex flex-column">
                                                <div>
                                                    Price
                                                </div>
                                                    ${priceListHTML}

                                            </div>
                                            <div class="d-flex flex-column">
                                                <div>
                                                    In-Stock
                                                </div>
                                                    ${stockListHTML}

                                            </div>
                                        </div>
                                    </div>
                            
                            
                            `;
                            scrollDiv.append(productElement);
                        });
                    } else {
                        scrollDiv.append('<div class="text-muted mt-3">No devices found</div>');
                    }

                },
                error: function (xhr, status, error) {
                    console.error('Failed to fetch devices:', error);
                }
            });   
        }         
    }
    function calculateTotalPrice(){
    let totalPrice = 0;
    let prices = document.querySelectorAll('#cart-table .total-price');
        prices.forEach(priceElement => {
            let price = Number(
                priceElement.textContent
                    .trim()
                    .replace(/[$,]/g, ''));
                        if (!isNaN(price)) {
            totalPrice += price;
            }
        });
        $('#total-cart-price').text(`Total = $${Number(totalPrice).toLocaleString('en-US')}`)

    }


    function updateCart(cart_id, quantity, calculate, id ,beforeINputQuantity) {
        $.ajax({
          url: '/update_cart_items',  
          type: 'PATCH',        
          data: {
            cart_id: cart_id,    
            quantity: quantity,
            calculate: calculate,  
            authenticity_token: $('meta[name="csrf-token"]').attr('content')
          },
          success: function(response) {
            const newUpdatedAt = Math.floor(new Date(response.cart_item.updated_at).getTime() / 1000) * 1000;
            let quantityUpdate = $(`#${id}-stock`);
            quantity_value = Number($(`#${id}-quantity`).val())
            if (calculate === "plus"){
                quantityUpdate.text(Number(quantityUpdate.text()) - 1  )
    
            }else if (calculate == "input"){
                quantityUpdate.text((Number(quantityUpdate.text()) + Number(beforeINputQuantity)) - quantity  )
                
            }
            
            else{
                quantityUpdate.text(Number(quantityUpdate.text())  + 1  )
                
            }
            $(`#${id}-quantity`).attr('data-quantity', quantity_value);
            const $timerElement = $(`.timer[data-id="${cart_id}"]`);

            $timerElement.attr('data-updated-at', newUpdatedAt);
            $timerElement.text('15:00');


          },
          error: function(xhr, status, error) {
            console.log('Error updating cart:', error);
          }
        });
      }

      function cartInputChange(event, cartItemId){

        let inventory_id = event.target.getAttribute('data-inventory');
        let value = event.target.value;
        
        if (value <= 0){
            alert("Quantity must be greater than 0");
            event.target.value = 1
            return
        }
        let availableStock = Number($(`#${inventory_id}-stock`).text());
        let quantity = $(`#${inventory_id}-quantity`);
        let total_price = $(`#${inventory_id}-total-price`); 
        let priceText = $(`#${inventory_id}-base-price`).text(); 
        let price = priceText.trim().replace(/[$,]/g, '')
        let beforeINputQuantity = event.target.getAttribute('data-quantity');
        availableStock = availableStock + Number(beforeINputQuantity)
        if (availableStock >= value) {
            quantity.val(value);
            total_quantity = parseFloat( quantity.val())
            total_price.text(`$${(Number(price) * total_quantity).toLocaleString('en-US')}`);
            calculateTotalPrice()
            updateCart(cartItemId, Number(total_quantity), "input" , inventory_id, Number(beforeINputQuantity))
        } else {
            quantity.val(availableStock);
            total_quantity = parseFloat( quantity.val())
            total_price.text(`$${parseFloat(price * total_quantity)}`)
            calculateTotalPrice()
            updateCart(cartItemId, Number(total_quantity), "input" , inventory_id, Number(beforeINputQuantity))
            alert("Cannot increase quantity beyond available stock!");
        }

      }

    function minus(id ,cartItemId) {
        let quantity = $(`#${id}-quantity`);
        let priceText = $(`#${id}-base-price`).text(); 
        let price = priceText.trim().replace(/[$,]/g, '')
        let total_price = $(`#${id}-total-price`); 
        if (Number(quantity.val()) > 0){
            quantity.val(Number(quantity.val()) - 1);
            total_quantity = parseFloat( quantity.val())
            total_price.text(`$${Number(price * total_quantity).toLocaleString('en-US')}`)
            if ((Number(quantity.val())) === 0){
                $(`#cart-item-${cartItemId}`).remove();
            }
           if ($('#cart-table tbody tr').length === 1) {
            $('#cart-data').html(`<h2 class="text-center"> No cart Items present </h2>`)
           }
       }
       
       calculateTotalPrice()
       updateCart(cartItemId, Number(total_quantity),  "minus" , id)
    }
   function plus(id, cartItemId) {
       let stock = Number($(`#${id}-stock`).text()); 
       let priceText = $(`#${id}-base-price`).text(); 
       let price = priceText.trim().replace(/[$,]/g, '')
       let total_price = $(`#${id}-total-price`); 
       let quantity = $(`#${id}-quantity`);
       let currentQuantity = Number(quantity.val());
       
       if (stock !== 0) {
           quantity.val(currentQuantity + 1);
           total_quantity = parseFloat( quantity.val())
           total_price.text(`$${Number(price * total_quantity).toLocaleString('en-US')}`)
           calculateTotalPrice()
           updateCart(cartItemId, Number(total_quantity), "plus" , id)



       } else {
           alert("Cannot increase quantity beyond available stock!");
       }
   }

    function cart(productId, inventoryId, element, stock){
        let quantityInput = document.getElementById(`${inventoryId}-quantity`);
        let quantityInputValue = Number(document.getElementById(`${inventoryId}-quantity`).value);

        if (quantityInputValue >= 1 && quantityInputValue <= stock) {
            quantityInput.value = quantityInputValue;
        } else {
            if (quantityInputValue <= 0) {
                toastr.error("Quantity cannot be less than One (1).");
            } else if (quantityInputValue > stock) {
                toastr.error(`Stock is not available. Maximum available stock is  ${stock}.`);
                return

            }
        }
        element.onclick = null;     
        let priceText = $(`#${inventoryId}-price`).text();  
        let price = priceText.replace('$', '');
        var csrfToken = $('meta[name="csrf-token"]').attr('content');
        quantity =  document.getElementById(`${inventoryId}-quantity`).value;

        $.ajax({
            url: '/add-to-cart', 
            type: 'POST',
            data: {
              product_id: productId,
              price: price, 
              inventory_id: inventoryId,
              quantity: quantity
            },
            headers: {
                'X-CSRF-Token': csrfToken
            },
            success: function(response) {
                stock = $(`#${inventoryId}-stock`)
                stock.text(Number(stock.text()) - Number(quantity))

                $('#addToCart').modal('show')
                var cartCount = Number($('#cart-count').text());
                $('#cart-count').text(response.cart_count)
                setTimeout(function() {
                    $('#addToCart').modal('hide'); // Hide the modal
                }, 1500);
                if (stock.text() == "0"){
                    // Instead of refreshing the entire product list, just disable this specific variant
                    const currentRow = element.closest('tr');
                    
                    // Disable the add to cart button for this variant
                    element.removeClass('cursor-pointer p-2 bid-css')
                          .addClass('disabled text-muted p-2')
                          .text('Out of Stock')
                          .attr('onclick', '')
                          .css('pointer-events', 'none');
                    
                    // Update the bid button to also be disabled
                    const bidBtn = currentRow.find('span[onclick*="clickPopUp"]');
                    bidBtn.removeClass('cursor-pointer')
                          .addClass('disabled text-muted')
                          .text('Unavailable')
                          .css('pointer-events', 'none');
                    
                    // Disable quantity controls for this variant
                    const quantityControls = currentRow.find(`#${inventoryId}-quantity-cart`);
                    quantityControls.find('span').css('pointer-events', 'none').addClass('text-muted');
                    quantityControls.find('input').prop('disabled', true);
                    
                    // Add visual indicator that this variant is out of stock
                    currentRow.addClass('out-of-stock')
                             .css('opacity', '0.6');
                    
                    // Show a toast notification
                    toastr.info('This variant is now out of stock, but other variants may still be available.');
                }
                

            },
            error: function(xhr, status, error) {
                toastr.error('Error adding to cart: ' + error);
            }
          });
    }  


    function changeQuantity(id, change, stock) {
        let quantityInput = document.getElementById(`${id}-quantity`);
        let currentQuantity = parseInt(quantityInput.value);
        let newQuantity = currentQuantity + change;
    
        if (newQuantity >= 1 && newQuantity <= stock) {
            quantityInput.value = newQuantity;
        } else {
            if (newQuantity <= 0) {
                toastr.error("Quantity cannot be less than One (1).");
            } else if (newQuantity > stock) {
                toastr.error(`Stock is not available. Maximum available stock is ${stock}.`);

            }
        }
    }

    
    
    function validateQuantity(productId, stock) {
        let quantityInput = document.getElementById(`${productId}-quantity`);
        let currentQuantity = parseInt(quantityInput.value);
                if (currentQuantity < 0) {
            quantityInput.value = 0;
        } else if (currentQuantity > stock) {
            quantityInput.value = stock;
        }
    }
    

    function collectCartData() {
        const orderItems = [];
        const inputs = $('#cart-table input[data-product-id]');
    
        if (inputs.length === 0) {
            console.warn('No cart items found.');
            return orderItems; 
        }
    
        inputs.each(function() {
            const $input = $(this); 
            const quantity = parseFloat($input.val()) || 0;
            const price = parseFloat($input.data('price')) || 0;
    
            if ($input.data('product-id') && quantity > 0) {
                orderItems.push({
                    product_id: $input.data('product-id'),
                    quantity: quantity,
                    price: price,
                    inventory_id: $input.data('inventory')
                });
            } else {
                console.warn(`Skipping item with invalid data:`, $input[0]);
            }
        });
    
        return orderItems;
    }

    $('#open-warning').click(function() {
        let forwarder = $('#forwarder').val();
        if(forwarder === '' ||  forwarder === null ){
            toastr.error('Please Select the Forwarder');
            return;

        }

        $('#warning').modal('show')
    });

    function cancel() {
        $('#warning').modal('hide')
    }

    function proceed() {
        let totalPrice = parseFloat($('#total-cart-price').text().replace(/[^\d.]/g, '').trim());
        let buyerId = $('#buyer_id').val()
        var csrfToken = $('meta[name="csrf-token"]').attr('content');
        let orderItems = collectCartData();
        let forwarder = $('#forwarder').val();
        $('#warning-content').remove();

        $('#loader').addClass("d-flex").removeClass("d-none")
        $.ajax({
            url: '/orders',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                order: {
                    total_amount: totalPrice,
                    buyer_id: buyerId,
                    forwarder: forwarder
                },
                order_items: orderItems,
            }),
            headers: {
                'X-CSRF-Token': csrfToken
            },
            success: function(response) {

                $('#loader').addClass("d-none").removeClass("d-flex")

                $('#cart-data').remove();
                $('#warning').modal('hide');
                $('#success-message').modal('show')
                console.log("Order created successfully:", response);
            },
            error: function(xhr, status, error) {
                $('#loader').addClass("d-none").removeClass("d-flex")
                $("#warning").modal("hide");
                
                let errorMessage = 'An error occurred while creating your order. Please try again.';
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response && response.error) {
                        errorMessage = response.error;
                    }
                } catch (e) {
                    console.error("Error parsing response:", e);
                }
                
                console.error("Error creating order:", errorMessage);
                toastr.error(errorMessage);
            }
        });
    }

    function clickPopUp (id, product_id, name, sku, price, variant, stock, model_number){
        $(`#${id}-dropdown`).addClass('d-block').removeClass('d-none')
        $('#inventoryId').val(id);
        $('#passId').val(id);
        $('#product-name').val(name);
        $('#product-sku').val(sku);
        $('#price').val(Number(price));
        $('#product-variant').val(variant);
        $('#stock-available').val(stock);
        $('#model-number').val(model_number);

        let bidQuantity = $(`#${id}-quantity`).val();
        $('#bid-quantity').val(bidQuantity);
        $('#exampleModal').modal('show');
    }

    function close(){
        $('#exampleModal').modal('hide');
   
    }

    function priceCheck(price, event) {
        let basePriceText = $(`#${price}-price`).text();
        let basePrice = parseFloat(basePriceText.trim().replace(/[$,]/g, ''));  
        
        let minPrice = Math.round(basePrice * 0.95);
        let enteredPriceText = event.target.value;
        let enteredPrice = parseFloat(enteredPriceText.trim().replace(/[$,]/g, ''));
    
        // Find the error message element
        const errorMessageEl = $(event.target).siblings('.bid-error-message');
        if (errorMessageEl.length === 0) {
            $(event.target).after('<small class="text-danger bid-error-message" style="display: none;">Bid price error</small>');
        }
        
        // Handle NaN values
        if (isNaN(enteredPrice)) {
            toastr.error('Please enter a valid number');
            $(event.target).addClass('is-invalid');
            $(event.target).data('valid', 'false');
            errorMessageEl.text('Please enter a valid number').show();
            return;
        }

        // Check if the price is within acceptable range
        if (enteredPrice < minPrice) {
            toastr.error(`The price cannot be less than 95% of the base price, which is $${minPrice}`);
            // Mark the field as invalid
            $(event.target).addClass('is-invalid');
            $(event.target).data('valid', 'false');
            errorMessageEl.text(`Bid price must be at least $${minPrice} (95% of base price)`).show();
        } else if (enteredPrice > basePrice) {
            toastr.error(`The price cannot exceed the base price of $${basePrice}. Please enter a lower price.`);
            // Mark the field as invalid
            $(event.target).addClass('is-invalid');
            $(event.target).data('valid', 'false');
            errorMessageEl.text(`Bid cannot exceed base price of $${basePrice}`).show();
        } else {
            // Price is valid
            event.target.value = Math.round(enteredPrice);
            $(event.target).removeClass('is-invalid');
            $(event.target).data('valid', 'true');
            errorMessageEl.hide();
        }
    }

    $('#popupForm').submit(function(event) {
        event.preventDefault();
        
        // Get price input and validate it
        const priceInput = $('input[name="quoted_price"]');
        const passId = $('#passId').val();
        
        // Get the base price for validation
        let basePriceText = $(`#${passId}-price`).text();
        let basePrice = parseFloat(basePriceText.trim().replace(/[$,]/g, ''));
        let minPrice = Math.round(basePrice * 0.95);
        let enteredPrice = parseFloat(priceInput.val().trim().replace(/[$,]/g, ''));
        
        // Get the error message element
        const errorMessageEl = priceInput.siblings('.bid-error-message');
        if (errorMessageEl.length === 0) {
            priceInput.after('<small class="text-danger bid-error-message" style="display: none;">Bid price error</small>');
        }
        
        // Validate price range
        let isValid = true;
        
        // Check for NaN
        if (isNaN(enteredPrice)) {
            toastr.error('Please enter a valid number');
            priceInput.addClass('is-invalid');
            errorMessageEl.text('Please enter a valid number').show();
            isValid = false;
        }
        // Check if below minimum
        else if (enteredPrice < minPrice) {
            toastr.error(`The price cannot be less than 95% of the base price, which is $${minPrice}`);
            priceInput.addClass('is-invalid');
            errorMessageEl.text(`Bid price must be at least $${minPrice} (95% of base price)`).show();
            isValid = false;
        }
        // Check if above maximum 
        else if (enteredPrice > basePrice) {
            toastr.error(`The bid price cannot exceed the base price of $${basePrice}. Please correct your bid.`);
            priceInput.addClass('is-invalid');
            errorMessageEl.text(`Bid cannot exceed base price of $${basePrice}`).show();
            isValid = false;
        }
        
        // If validation fails, stop here
        if (!isValid) {
            return false;
        }
        
        // Only if the price is valid, proceed with form submission
        const formData = $(this).serialize();
        var csrfToken = $('meta[name="csrf-token"]').attr('content');
        
        // Show loading indicator
        const submitBtn = $(this).find('button[type="submit"]');
        const originalBtnText = submitBtn.text();
        submitBtn.prop('disabled', true).text('Submitting...');
        
        $.ajax({
            url: '/buyers_bids',  
            method: 'POST',
            data: formData,
            headers: {
                'X-CSRF-Token': csrfToken
            },
            success: function (response) {
                window.location.href = "my-bids";
                $('#exampleModal').modal('hide');
            },
            error: function (xhr) {
                // Re-enable button
                submitBtn.prop('disabled', false).text(originalBtnText);
                
                // Display the error message from the server
                if (xhr.responseJSON && xhr.responseJSON.error) {
                    toastr.error(xhr.responseJSON.error);
                } else {
                    toastr.error('An error occurred while submitting your bid. Please try again.');
                }
                console.log('Error submitting form:', xhr);
            }
        });
    });

    function changeQuantityInput(id ,   stock , event){
        let quantityInput = document.getElementById(`${id}-quantity`);
        newQuantity = event.target.value

        if (newQuantity >= 1 && newQuantity <= stock) {
            quantityInput.value = newQuantity;
        } else {
            if (newQuantity <= 0) {
                toastr.error("Quantity cannot be less than One (1).");
            } else if (newQuantity > stock) {
                // quantityInput.value = stock;
                toastr.error(`Stock is not available. Maximum available stock is  ${stock}.`);

            }
        }
     }

     function deleteItem(cartItemId) {
        if (confirm("Are you sure you want to delete this item?")) {
            var csrfToken = $('meta[name="csrf-token"]').attr('content');
            $.ajax({
                url: '/delete_item',  
                method: 'DELETE',
                data: {id: cartItemId},
                headers: {
                    'X-CSRF-Token': csrfToken
                },
                success: function (response) {
                    if (response.success) {
                        // Get the inventory ID from the cart item's quantity input
                        const cartItem = $(`#cart-item-${cartItemId}`);
                        const inventoryId = cartItem.find('.quantity-input').data('inventory');
                        
                        // Update the stock display with the new stock value
                        if (response.new_stock !== undefined) {
                            $(`#${inventoryId}-stock`).text(response.new_stock);
                        }

                        // Remove the cart item from display
                        cartItem.remove();
                        calculateTotalPrice();

                        // Update empty cart message if needed
                        if ($('#cart-table tbody tr').length === 1) {
                            $('#cart-data').html(`<h2 class="text-center m-0"> No cart Items present </h2>`);
                        }
                    } else {
                        alert(response.message || 'Failed to delete item.');
                    }
                },
                error: function (error) {
                    console.error('Error deleting:', error);
                    alert('Failed to delete item. Please try again.');
                }
            });
        } else {
            console.log("Deletion canceled by the user.");
        }
    }

    $('#openDetailModal').click(function(event) {
        event.preventDefault()
        $('#detailModal').modal('show')
    });  
    
    $(document).on('click', '#close-stats', function () {
        $('#SellerbrandStatsModal').modal('hide');
     });
    