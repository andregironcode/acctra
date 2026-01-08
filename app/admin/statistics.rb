ActiveAdmin.register_page "Statistics" do
  menu label: "statistics", parent: "Dashboard"
  controller do
    def statistics_filter
      category_sales = {}
      if params[:start_date].present? || params[:end_date].present?
        start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
        end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
      
        if start_date && end_date
          orders = Order.where('orders.created_at BETWEEN :start_date AND :end_date', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day)
        elsif start_date
          orders = Order.where('orders.created_at >= :start_date', start_date: start_date.beginning_of_day)
        elsif end_date
          orders = Order.where('orders.created_at <= :end_date', end_date: end_date.end_of_day)
        else
          orders = Order.all
        end
      else
        orders = Order.all
      end
      new_count = orders.where(status: "created").count
      processing_count = orders.where(status: "processing").count
      completed_count = orders.where(status: "completed").count
      max_order_count = [new_count, processing_count, completed_count].max


      orders.all.each do |order|
        order.order_items.each do |item|
          quantity = item.quantity || 0
          price = item.price || 0.0
      
          category = item.product.brand
          next unless category # Skip if no category is associated with the product
      
          category_id = category.id
          category_name = category.name
      
          category_sales[category_id] ||= { name: category_name, sales: 0 }
          category_sales[category_id][:sales] += quantity * price
        end
      end
      
      # Maximum sales value
      max_category_sales = category_sales.values.map { |v| v[:sales] }.max
      
      # Sorting by sales in descending order and taking the top 4
      sorted_category_sales = category_sales.map do |id, data|
        { id: id, name: data[:name], sales: data[:sales] }
      end.sort_by { |entry| -entry[:sales] }.first(4)

      top_sellers = orders.top_sellers(start_date, end_date)
      top_selling_products = Product.top_selling_products(6,nil,start_date, end_date )


      render json: { 
        orders: orders, 
        new_count: new_count,
        processing_count: processing_count,
        completed_count: completed_count,
        max_order_count: max_order_count,
        max_category_sales: max_category_sales,
        sorted_category_sales: sorted_category_sales,
        top_sellers: top_sellers,
        top_selling_products:top_selling_products,
      }, status: :ok
    end

    def brand_stats_devices
      brand_sales = {}
    
      brand = Brand.find_by(id: params[:id])
      
      if brand
        brand.devices.includes(products: { inventories: :order_items }).each do |device|
          
          device.products.each do |product|
            
            product.inventories.each do |inventory|
              
              inventory.order_items.each do |order_item|
                quantity = order_item.quantity || 0
                price = order_item.price || 0.0
                device_name = device.name || "Unknown" 
                brand_sales[device_name] ||= { name: device_name, sales: 0 }
                brand_sales[device_name][:sales] += quantity * price
              end
            end
          end
        end
        
        brand_sales = brand_sales.map do |device_name, data|
          { name: device_name, sales: data[:sales] }
        end.sort_by { |entry| -entry[:sales] }       end
      
      render json: {brand_sales: brand_sales, brand_name: brand.name}
    end

    def brand_stats_models
      models_sales = {}
      brand = Brand.find_by(name: params[:brand_name])
      device = Device.find_by(name: params[:name], brand_id: brand.id)
      
      if device

        device.categories.includes(products: { inventories: :order_items }).each do |category|
          
          category.products.each do |product|
            
            product.inventories.each do |inventory|
              
              inventory.order_items.each do |order_item|
                quantity = order_item.quantity || 0
                price = order_item.price || 0.0
                category_name = category.name || "Unknown" 
                models_sales[category_name] ||= { name: category_name, sales: 0 }
                models_sales[category_name][:sales] += quantity * price
              end
            end
          end
        end
        models_sales = models_sales.map do |category_name, data|
          { name: category_name, sales: data[:sales] }
        end.sort_by { |entry| -entry[:sales] }       end
      render json: {models_sales: models_sales, brand_id: brand.id, device_id: device.id}
  
    end

    def brand_stats_products
      products_sales = {}
      brand = Brand.find_by(id: params[:brand_id])
      device = Device.find_by(id: params[:device_id], brand_id: brand.id)
      category = Category.find_by(name: params[:name], device_id: device.id, brand_id: brand.id)

      if category
        category.products.each do |product|
          product_variant = product.variant || "No variant" 

          product.inventories.each do |inventory|
            inventory.order_items.each do |order_item|
              quantity = order_item.quantity || 0
              price = order_item.price || 0.0
              product_name = product.name || "Unknown"
              products_sales[product.id] ||= { 
                id: product.id, 
                name: product_name, 
                variant: product_variant, 
                sales: 0 
              }
            products_sales[product.id][:sales] += quantity * price
            end
          end
        end

        products_sales = products_sales.map do |_, data|
          { 
            id: data[:id], 
            name: data[:name], 
            variant: data[:variant],  # Include the variant in the result
            sales: data[:sales] 
          }
        end.sort_by { |entry| -entry[:sales] }
      end

      render json: { models_sales: products_sales }
    end

    
  end
 

  content do
   
    @new_orders_count =Order.where(status: "created").count
    @processing_orders_count =Order.where(status: "processing").count
    @completed_orders_count =Order.where(status: "completed").count
    @max_order_count = [@new_orders_count, @processing_orders_count, @completed_orders_count].max
    @top_selling_products = Product.top_selling_products(6)
    @percentage_sales = Order.percentage_change_in_orders(nil, 'sales')
    @percentage_change = Order.percentage_change_in_orders(nil, 'orders')
    @percentage_confirmed = Order.percentage_change_in_orders(nil, 'completed')
    @percentage_users = User.percentage_created_today
    @top_sellers = Order.top_sellers


    @category_sales = {}

    Order.all.each do |order|
      order.order_items.each do |item|
        quantity = item.quantity || 0
        price = item.price || 0.0
    
        category = item.product.brand
        next unless category # Skip if no category is associated with the product
    
        category_id = category.id
        category_name = category.name
    
        @category_sales[category_id] ||= { name: category_name, sales: 0 }
        @category_sales[category_id][:sales] += quantity * price
      end
    end
    
    # Maximum sales value
    @max_category_sales = @category_sales.values.map { |v| v[:sales] }.max
    
    # Sorting by sales in descending order and taking the top 4
    @sorted_category_sales = @category_sales.map do |id, data|
      { id: id, name: data[:name], sales: data[:sales] }
    end.sort_by { |entry| -entry[:sales] }.first(4)
    div class: "d-flex mb-2  justify-content-end " do
      dropdown_button = content_tag :button,
      class: "d-flex align-items-center rounded-pill dropdown-toggle border filter-btn-round p-2 px-3",
      id: "filterDropdown",
      type: "button",
      data: { toggle: "dropdown" },
      aria: { haspopup: "true", expanded: "false" } do
    image_tag('filter.svg', alt: 'Search', class: 'mx-2') + " Filter"
      end
    
      dropdown_menu = <<~HTML
      <div class="dropdown-menu p-3" style="width: 360px;">
      <label class="form-label fw-bold">Order By</label>

      <div class="mb-3">
      <label class="form-label">Date</label>
      <div class="input-group">
      <input type="date" class="form-control" id="adminStatsStartDate">
      <div class="input-group-append">
      <span class="input-group-text">→</span>
      </div>
      <input type="date" class="form-control" id="adminStatsEndDate">
      </div>
      </div>

      <!-- Apply Button -->
      <div class="d-flex align-items-center justify-content-between">
      <button class="btn btn-danger" id="statsReset">Reset</button>
      <button class="btn btn-primary" id="statsApplyCustomDate">Apply</button>
      </div>
      </div>
      HTML

      content_tag :div, class: "dropdown" do
      dropdown_button + raw(dropdown_menu)
      end
    end
     
    
      div class: "d-flex setFlexStaticsCharts" do



        
        div class: "w-75 flex-column setFlexStaticsChartsWidth" do
          div class: "row justify-content-between px-3 setFlexStaticsChartsContent mobile-padding" do
            div class: "col-xl-6 chartMain setPaddingCard borderNone shadow mb-2 setHeightStatsOrdr" do
              div class: "chart-title-statics mb-3 stats-mb" do
                span do
                  link_to 'Total Orders', admin_orders_path
                end
              end
              div class:"orders-stats stats-statics" do

              div class: "stats-bar order-bar ", "data-value": "#{@new_orders_count}" do
                div class: "label-statics" do
                 link_to "New","/admin/orders?scope=new"
                end
                div class: "bar-container-statics d-flex align-items-center" do
                  div class: "bar-fill-statics"
                  div class: "dolarSet ml-1" do
                    span do
                      @new_orders_count
                    end
                  end
                end
              end
  
              div class: "stats-bar order-bar",  "data-value": "#{@processing_orders_count}" do
                div class: "label-statics" do
                  link_to "Processing","/admin/orders?scope=processing"

                end
                div class: "bar-container-statics d-flex align-items-center" do
                  div class: "bar-fill-statics-proces bar-fill-statics"
                  div class: "dolarSet ml-1" do
                    span do
                      @processing_orders_count
                    end
                  end
                end
              end
  
              
  
              div class: "stats-bar order-bar", "data-value": "#{@completed_orders_count}" do
                div class: "label-statics" do
                  link_to "Completed","/admin/orders?scope=completed"
                end
                div class: "bar-container-statics d-flex align-items-center" do
                  div class: "bar-fill-statics-cmplt bar-fill-statics"
                  div class: "dolarSet ml-1" do
                    span do
                      Order.where(status: "completed").count
                    end
                  end
                end
              end
              end
            
  
           
              div class: "axis-orders d-none" do
                span { "0" }
                span id:"firstStatsValue" do  
                end
                span id:"secondStatsValue" do
                end
                span id:"thirdStatsValue" do
                end
                span id: "maxStatsValue"do
                "#{@max_order_count}"
                end
              end
            end
  
            div class: "col-xl-6 chartMain borderNone setPaddingCard shadow mb-2 setHeightStatsOrdr" do
              div class: "chart-title-statics mb-3 stats-mb" do
                span do
                  a href: "/admin/brands" do
                    "Brands"
                  end
                end
              end
        
              div class: "category-sales" , id:"model-sales" do
                @sorted_category_sales.each_with_index do |category, index|
                  div class: "category-bar categoryBar", data: { value: category[:sales] } do
                    a href: "/admin/brands/#{category[:id]}", data: { id: category[:id] ,sales: category[:sales] }, id: "brand-stats" do
                      div class: "label-statics-category" do
                        span category[:name]
                      end
                    end
        
                    div class: "bar-container-statics-category d-flex align-items-center" do
                      div class: "bar-fill-statics-category category#{index + 1}"
                      div class: "dolarSet ml-1" do
                        span "#{ number_to_currency(category[:sales], precision: 0)}"
                      end
                    end
                  end
                end
              end
        
              # Axis statics (values)
              div class: "axis-statics" do
                span "0"
                span id: "firstCatValue" do
                  # Add the dynamic content if needed
                end
                span id: "secondCatValue" do
                  # Add the dynamic content if needed
                end
                span id: "thirdCatValue" do
                  # Add the dynamic content if needed
                end
                span id: "maxCategoryValue" do
                  "#{number_to_currency(@max_category_sales,  precision: 0 )}"
                end
              end
            end
          end
        
          
          
          div class: "row px-3 mobile-padding" do
          div class: "mb-2 shadow chart-container-seller borderNone setPaddingCard col-12" do
            div class: "" do
            
              div id:"top-sellers" do  
                @top_sellers.each_with_index do |seller, index|
                  span  id: "topSeller#{index}", class: "d-none", data: { value: seller.total_revenue , lastName: seller.last_name}
                end
              end
  
              div class: "chart-wrapper-seller" do
                tag.canvas id: "apexcharts-bar", style: "height: 20.9rem; width: 100%;"
              end
            end
          end
          end
        end
  
        div class: "col-xl-3 col-lg-12 mobile-padding new-padding" do
          div class: "card shadow borderNone setPaddingCard" do
            div class: "d-flex flex-row align-items-center justify-content-between" do
              h6 class: "m-0 sellingProductsText" do
                span "Top Selling Product"
              end
  
            end
  
            hr class: "sidebar-divider hrColor"
  
            div class: "card-body setOverFlowStates" do
              div class: "productsSellingParent" do
                div id: "top-products" do

                  @top_selling_products.each do |product|
                    html = <<~HTML
                  <a href="/admin/products/#{product.id}" class="full-width-link">
                    <div class="sellingProducts mt-4">
                      <div class="flag_alignment d-flex">
                        <div class="productMemory">
                          <span class="flag flag-icon flag-icon-#{product.country.downcase} flag-icon-squared"></span>
                        </div>
                        <div class="productName">
                          <div>#{product.name}</div>
                          <div class="productMemory">#{product.variant}</div>
                        </div>
                      </div>
                      <div class="productPrice">
                        <div>#{number_to_currency(product.total_sales.round, precision: 0)}</div>
                        <div class="productSales">#{product.total_quantity_sold} sales</div>
                      </div>
                    </div>
                  </a>
                HTML
                div do
                raw(html)
                end
                  end
                end  
            end  
            end
            div do
              link_to "VIEW STATS", "/admin/statistics", class: "invisible btn setBtnStats mt-3"
            end
          end
        end
      end

      div do
        div class: "tdySalesTextFnt my-2 ml-2" do
          span "Today’s Sales"
        end
  
        div class: "row justify-content-between" do
          div class: 'col-xl-3 col-md-6 mb-2 mobile-padding' do
            raw_html = <<~HTML
              <a href="/admin/orders?order=id_desc&q%5Bcreated_at_gteq%5D=#{Time.zone.now.strftime('%Y-%m-%d')}&scope=completed" class="text-decoration-none order-link">
                <div class="card h-100 borderNone boxShadowSet">
                  <div class="card-body setPaddingCard">
                    <div class="row no-gutters align-items-start">
                      <div class="col orderFlex">
                        <div class="orderText">
                          Total Sales
                        </div>
                        <div class="h5 mb-0 font-weight-bold textGray800 orderNumber">
                          #{number_to_currency(Order.todays_total_sales  , precision: 0)}
                        </div>
                        <div class="d-flex align-items-center setGap">
            HTML
          
            percentage_html = if @percentage_sales >= 0
              <<~HTML
                <div>
                  #{image_tag('ic-trending-up-24px.svg', alt: 'Trending Up')}
                </div>
                <div class="chngeColor">
                  <span>#{Order.percentage_change_in_orders(nil, 'sales').abs}%</span>
                </div>
                <span>Up from yesterday</span>
              HTML
            else
              <<~HTML
                <div>
                  #{image_tag('Path.svg', alt: 'Trending Down')}
                </div>
                <div class="chngeColorRed">
                  <span>#{Order.percentage_change_in_orders(nil, 'sales').abs}% </span>
                </div>
                <span>Down from yesterday</span>
              HTML
            end
          
            remaining_html = <<~HTML
                        </div>
                      </div>
                      <div class="col-auto">
                        #{image_tag('Icon (1).svg', alt: 'Icon')}
                      </div>
                    </div>
                  </div>
                </div>
              </a>
            HTML
          
            raw("#{raw_html}#{percentage_html}#{remaining_html}")
          end
  
          # Total Orders Card
          div class: "col-xl-3 col-md-6 mb-2 mobile-padding" do
              raw_html = <<~HTML
                <a href="/admin/orders?order=id_desc&q%5Bcreated_at_gteq%5D=#{Time.zone.now.strftime('%Y-%m-%d')}&scope=all" class="text-decoration-none">
                  <div class="card h-100 borderNone boxShadowSet">
                  <div class="card-body setPaddingCard">
                    <div class="row no-gutters align-items-start">
                      <div class="col orderFlex">
                        <div class="orderText">
                          <span>Total Orders</span>
                        </div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800 orderNumber">
                          <span>

                    #{Order.todays_all_orders.count}
                 
                  </span>
                </div>
                <div class="d-flex align-items-center setGap">
                 HTML
                 percentage_html = if @percentage_sales >= 0
                  <<~HTML
                    <div>
                      #{image_tag('ic-trending-up-24px.svg', alt: 'Trending Up')}
                    </div>
                    <div class="chngeColor">
                      <span>#{Order.percentage_change_in_orders(nil, 'sales').abs}%</span>
                    </div>
                    <span>Up from yesterday</span>
                  HTML
                  else
                  <<~HTML
                    <div>
                      #{image_tag('Path.svg', alt: 'Trending Down')}
                    </div>
                    <div class="chngeColorRed">
                      <span>#{Order.percentage_change_in_orders(nil, 'orders').abs}% </span>
                    </div>
                    <span>Down from yesterday</span>
                  HTML
                  end
          
              remaining_html = <<~HTML
                          </div>
                        </div>
                        <div class="col-auto">
                          #{image_tag('graph.svg', alt: 'Icon')}
                        </div>
                      </div>
                    </div>
                  </div>
                </a>
              HTML
          
                raw("#{raw_html}#{percentage_html}#{remaining_html}")
              end
          
  
          # Complete Orders Card
          div class: "col-xl-3 col-md-6 mb-2 mobile-padding" do
            raw_html = <<~HTML
            <a href="/admin/orders?order=id_desc&q%5Bcreated_at_gteq%5D=#{Time.zone.now.strftime('%Y-%m-%d')}&scope=completed" class="text-decoration-none">
              <div class="card h-100 borderNone boxShadowSet">
              <div class="card-body setPaddingCard">
                <div class="row no-gutters align-items-start">
                  <div class="col orderFlex">
                    <div class="orderText">
                      <span>Complete Orders</span>
                    </div>
                    <div class="h5 mb-0 font-weight-bold text-gray-800 orderNumber">
                      <span>

                #{Order.todays_orders.count}
             
              </span>
            </div>
            <div class="d-flex align-items-center setGap">
            HTML
            percentage_html = if @percentage_confirmed >= 0
              <<~HTML
                <div>
                  #{image_tag('ic-trending-up-24px.svg', alt: 'Trending Up')}
                </div>
                <div class="chngeColor">
                  <span>#{Order.percentage_change_in_orders(nil, 'completed').abs}%</span>
                </div>
                <span>Up from yesterday</span>
              HTML
              else
              <<~HTML
                <div>
                  #{image_tag('Path.svg', alt: 'Trending Down')}
                </div>
                <div class="chngeColorRed">
                  <span>#{Order.percentage_change_in_orders(nil, 'completed').abs}% </span>
                </div>
                <span>Down from yesterday</span>
              HTML
              end
      
          remaining_html = <<~HTML
                      </div>
                    </div>
                    <div class="col-auto">
                        #{image_tag('Icon (5).svg', alt: 'Icon')}
                    </div>
                  </div>
                </div>
              </div>
            </a>
          HTML
      
            raw("#{raw_html}#{percentage_html}#{remaining_html}")
          end
  
          # New Members Card
          div class: "col-xl-3 col-md-6 mb-2 mobile-padding" do
            raw_html = <<~HTML
            <a href="/admin/users?q%5Bcreated_at_gteq%5D=#{Time.zone.now.strftime('%Y-%m-%d')}&commit=Filter&order=id_desc" class="text-decoration-none">
              <div class="card h-100 borderNone boxShadowSet">
              <div class="card-body setPaddingCard">
                <div class="row no-gutters align-items-start">
                  <div class="col orderFlex">
                    <div class="orderText">
                      <span>New Members</span>
                    </div>
                    <div class="h5 mb-0 font-weight-bold text-gray-800 orderNumber">
                      <span>

                #{User.todays_new_member.count}
             
              </span>
            </div>
            <div class="d-flex align-items-center setGap">
            HTML
          
            percentage_html = if @percentage_users >= 0
              <<~HTML
                <div>
                  #{image_tag('ic-trending-up-24px.svg', alt: 'Trending Up')}
                </div>
                <div class="chngeColor">
                  <span>#{@percentage_users}%</span>
                </div>
                <span>Up from yesterday</span>
              HTML
            else
              <<~HTML
                <div>
                  #{image_tag('Path.svg', alt: 'Trending Down')}
                </div>
                <div class="chngeColorRed">
                  <span>#{Order.percentage_change_in_orders(nil, 'sales').abs}% </span>
                </div>
                <span>Down from yesterday</span>
              HTML
            end
          
            remaining_html = <<~HTML
                        </div>
                      </div>
                      <div class="col-auto">
                        #{image_tag('Icon (6).svg', alt: 'Icon')}
                      </div>
                    </div>
                  </div>
                </div>
              </a>
            HTML
          
            raw("#{raw_html}#{percentage_html}#{remaining_html}")
          end
        end
      end
      
      
        div class: "modal fade", id: "brandStatsModal", tabindex: "-1", "aria-labelledby": "exampleModalLabel", "aria-hidden": "true" do
          div class: "modal-dialog  modal-xl modal-dialog-centered" do
            div class: "modal-content" do
              div class: "modal-header" do
                h3 class: "modal-title stats-title", id: "exampleModalLabel" do
                  "STATISTICS"
                end
                button type: "button", class: "btn-close-stats" , id:'close-stats' do
                  span aria: { hidden: "true" } do
                    "&times;".html_safe
                  end
                end
              end
              div class: "modal-body" do
              end
            end
          end
        end
      


    end

    
end
