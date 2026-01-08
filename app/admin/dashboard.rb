# app/admin/dashboard.rb

ActiveAdmin.register_page "Dashboard" do
  controller do
    layout 'admin'
  end

  controller do
    # def recent_orders
    #   filter = params[:filter]
      
    #   case filter
    #   when 'today'
    #     @recent_orders = Order.where('created_at >= ?', Date.today.beginning_of_day).order(created_at: :desc).limit(3)
    #   when 'yesterday'
    #     @recent_orders = Order.where('created_at >= ? AND created_at < ?', Date.yesterday.beginning_of_day, Date.yesterday.end_of_day).order(created_at: :desc).limit(3)
    #   when 'one_week_ago'
    #     @recent_orders = Order.where('created_at >= ? AND created_at < ?', 1.week.ago.beginning_of_day, Date.today.beginning_of_day).order(created_at: :desc).limit(3)
    #   else
    #     @recent_orders = Order.where('created_at >= ?', Date.today.beginning_of_day).limit(3)
    #   end
      
    #   render partial: 'admin/dashboard/recent_orders_table', locals: { orders: @recent_orders }
    # end

    def dashboard_filter
      product_counts = {}
      if params[:start_date].present? || params[:end_date].present?
        start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
        end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
      
        # Handle cases where only start_date or end_date is provided
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
    
      processing_count = orders.where(status: "processing").count
      total_sales = orders.where(status: "completed").sum(:total_amount)
    
      orders.each do |order|
        order.order_items.each do |item|
          product_name = item.product.category.name
          product_counts[product_name] ||= 0
          product_counts[product_name] += 1
        end
      end
    
      max_count = product_counts.values.max
      sorted_product_counts = product_counts.sort_by { |name, count| -count }.first(4)
      top_selling_products = Product.top_selling_products(3, nil, start_date, end_date)
    
      order_items_data = []
    
      orders.limit(3).each do |order|
        first_order_item = order.order_items.first
        
        if first_order_item
          order_items_data << {
            order_id: order.id,
            seller_name: first_order_item.inventory.seller.full_name,
            seller_id: first_order_item.inventory.seller.id,
            product_name: first_order_item.product.name,
            product_id: first_order_item.product.id,
            quantity: first_order_item.quantity,  
            price: first_order_item.price,
            sku: first_order_item.product.sku,
            status: order.status,
            created_at: order.created_at,
            total_amount: first_order_item.quantity * first_order_item.price
          }
        end
      end
    
      render json: { 
        orders: orders, 
        processing_count: processing_count,
        total_sales: total_sales, 
        max_count: max_count, 
        sorted_product_counts: sorted_product_counts, 
        top_selling_products: top_selling_products, 
        recent_orders: order_items_data 
      }, status: :ok
    end
    
    
    
  end
  

  content title: "Dashboard" do
    @product_counts = {}
    @recent_orders = Order.limit(3).order(created_at: :desc)


    Order.all.each do |order|
      order.order_items.each do |item|
        product_name = item.product.category.name
        @product_counts[product_name] ||= 0
        @product_counts[product_name] += 1
      end
    end
    @max_count = @product_counts.values.max
    @sorted_product_counts = @product_counts.sort_by { |name, count| -count }.first(4)
    @percentage_change = Order.percentage_change_in_orders(nil, 'orders')
     @percentage_sales = Order.percentage_change_in_orders(nil, 'sales')
     @pending_orders_change = Order.percentage_change_in_orders(nil, 'processing')
     @top_selling_products = Product.top_selling_products


    div class:"bg-color" do

      div class: "d-flex justify-content-end mb-2 " do
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
            <input type="date" class="form-control" id="adminDashStartDate">
            <div class="input-group-append">
            <span class="input-group-text">→</span>
            </div>
            <input type="date" class="form-control" id="adminDashEndDate">
            </div>
            </div>

            <!-- Apply Button -->
            <div class="d-flex align-items-center justify-content-between">
            <button class="btn btn-danger" id="adminDashFilterReset">Reset</button>
            <button class="btn btn-primary" id="apply-admin-filter-dash">Apply</button>
            </div>
            </div>
            HTML

            content_tag :div, class: "dropdown" do
            dropdown_button + raw(dropdown_menu)
          end
      end

      
      div class: "row justify-content-between" do
        div class: 'col-xl-4 col-md-6 mb-2 ' do
          raw_html = <<~HTML
            <a href="admin/orders?scope=all" class="text-decoration-none order-link" id="all">
              <div class="card h-100 borderNone">
                <div class="card-body setPaddingCard">
                  <div class="row no-gutters align-items-start">
                    <div class="col orderFlex">
                      <div class="orderText">
                        Total Orders
                      </div>
                      <div class="h5 mb-0 font-weight-bold textGray800 orderNumber" id="total_orders">
                        #{Order.count}
                      </div>
                      <div class="d-flex align-items-center setGap">
          HTML

          percentage_html = if @percentage_change >= 0
          <<~HTML
            <div>
              #{image_tag('ic-trending-up-24px.svg', alt: 'Trending Up')}
            </div>
            <div class="chngeColor">
              <span>#{Order.percentage_change_in_orders(nil, 'orders').abs}%</span>
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
                  #{image_tag('Icon (1).svg', alt: 'Icon')}
                </div>
              </div>
            </div>
          </div>
        </a>
      HTML

        raw("#{raw_html}#{percentage_html}#{remaining_html}")
      end
      div class: 'col-xl-4 col-md-6 mb-2 ' do
        raw_html = <<~HTML
          <a href="admin/orders?scope=completed" class="text-decoration-none order-link" id="sales">
            <div class="card h-100 borderNone">
              <div class="card-body setPaddingCard">
                <div class="row no-gutters align-items-start">
                  <div class="col orderFlex">
                    <div class="orderText">
                      Total Sales
                    </div>
                    <div class="h5 mb-0 font-weight-bold textGray800 orderNumber" id="total_sales">
                      #{number_to_currency(Order.total_sales , precision: 0)}
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
                #{image_tag('Icon (2).svg', alt: 'Icon')}
              </div>
            </div>
          </div>
        </div>
      </a>
    HTML

      raw("#{raw_html}#{percentage_html}#{remaining_html}")
    end
        div class: 'col-xl-4 col-md-6 mb-2 ' do
          raw_html = <<~HTML
            <a href="admin/orders?scope=processing" class="text-decoration-none order-link" id="processing">
              <div class="card h-100 borderNone">
                <div class="card-body setPaddingCard">
                  <div class="row no-gutters align-items-start">
                    <div class="col orderFlex">
                      <div class="orderText">
                        Processing Order
                      </div>
                      <div class="h5 mb-0 font-weight-bold textGray800 orderNumber" id="processing_count">
                        #{Order.where(status: "processing").count}
                      </div>
                      <div class="d-flex align-items-center setGap">
          HTML

          percentage_html = if @pending_orders_change >= 0
          <<~HTML
            <div>
              #{image_tag('ic-trending-up-24px.svg', alt: 'Trending Up')}
            </div>
            <div class="chngeColor">
              <span>#{Order.percentage_change_in_orders(nil, 'processing').abs}%</span>
            </div>
            <span>Up from yesterday</span>
          HTML
          else
          <<~HTML
            <div>
              #{image_tag('Path.svg', alt: 'Trending Down')}
            </div>
            <div class="chngeColorRed">
              <span>#{Order.percentage_change_in_orders(nil, 'processing').abs}% </span>
            </div>
            <span>Down from yesterday</span>
          HTML
          end

          remaining_html = <<~HTML
                  </div>
                </div>
                <div class="col-auto">
                  #{image_tag('Icon (3).svg', alt: 'Icon')}
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
    div class: "row" do
      div class: "col-xl-8 col-lg-7 col-sm-12 mb-2 " do
        div class:"shadow setPaddingCard orderChartBg borderNone" do
          div class: "chart-title" do
            "Total Orders"
          end
          div class: "chart-container" do
          div  class:"AdminsetHeightBars"  do
            @sorted_product_counts.each do |name, count|
              div class: "bar", data: { value: count } do
                div class: "label" do
                 name
                end
                div class: "bar-container" do
                  div class: "bar-fill" do
                     
                  end
                end
              end
            end
          end
            
            div class: "axis d-none" do
              span { "0" }
              span id:"firstValue" do
              end
              span id:"secondValue" do
              end
              span id:"thirdValue" do
              end
              span id:"max-count" do
                 "#{@max_count}"
              end
            end
          end
        end
      end

      div class: "col-xl-4 col-lg-5 col-sm-12" do
        div class:"card shadow mb-2 setPaddingCard borderNone"  do
          div class: "d-flex flex-row align-items-center justify-content-between" do
            h6 class: "m-0 sellingProductsText" do
              "Top Selling Product"
            end
          end

          hr class: "sidebar-divider hrColor" 
          div class: "card-body p-0" do
            div class: "productsSellingParent pt-1 setOverFlowDashBoard" do
              div id:"products-container" do
              if @top_selling_products.any?
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
              else
                div class:"text-center d-flex justify-content-center" do 
                  div do
                  "No top products present"
                end
              end
              
                  
              end
              end
            end
            
              div do
                link_to "VIEW STATS", "/admin/statistics", class: "btn setBtnStats mt-3"
              end
            
          end
        end
      end
    end

    div class: "" do
      div class: "col-lg-12 p-0 mb-4" do
        div class: "headerTableFlex setPaddingCard shadow borderNone" do
          div class: "heeaderTableOrder mobile-table" do
            div do
              "Recent Orders"
            end
            # div class: "monthNameFilter" do
            #   select_tag 'monthly_filter', options_for_select(
            #     [
            #       ['Today', 'today'],
            #       ['Yesterday', 'yesterday'],
            #       ['One Week Ago', 'one_week_ago']
            #     ]
            #   ), class: "monthNamesInput"
            # end
          end
      
          table class: "table setRecentOrderTble text-center mobile-table" ,id:"recentOrdersTable" do
            thead class: "tHeadBgColor" do
              tr do
                th "Seller Name"
                th "Product Name"
                th "SKU"
                th "Date - Time"
                th "Quantity"
                th "Amount"
                th "Status"
                th "Actions"
              end
            end
            tbody class: "setFontOrderTable" do
              if @recent_orders.present?
                any_order_with_items = false
                @recent_orders.each do |order|
                  if order.order_items.present?
                    any_order_with_items = true
                    order.order_items.limit(1).each do |item|
                      tr class: "setBorderBottomTr" ,onclick: "window.location='/admin/orders/#{order.id}'" do
                        td do
                          link_to item.inventory.seller.full_name, admin_user_path(item.inventory.seller.id)
                        end
                        td do
                          link_to item.inventory.product.name, admin_product_path(item.inventory.product.id)
                        end
                        td item.inventory.product.sku
                        td order.created_at.strftime("%d.%m.%Y - %I.%M %p")
                        td item.quantity
                        td do
                          "#{number_to_currency(item.inventory.price * item.quantity, precision: 0)}"
                        end
                        td do
                          button class: "badge-status text-light #{'bg-new' if order.status == 'created'} #{'bg-process' if order.status == 'processing'} #{'bg-secondary' if order.status == 'dispatched'} #{'bg-completed' if order.status == 'completed'}" do
                            order.status == "created" ? "New" : order.status.capitalize
                          end
                        end
                        td do
                          link_to 'View Order', admin_order_path(order.id)
                        end
                      end
                    end
                  end
                end
          
                # If no orders with items were found, display a message
                unless any_order_with_items
                  tr do
                    td colspan: 8, class: "text-center" do
                      "No recent orders with items."
                    end
                  end
                end
              else
                tr do
                  td colspan: 8, class: "text-center" do
                    "No recent orders present"
                  end
                end
              end
            end
          end
        end

      end
    end
  end
end