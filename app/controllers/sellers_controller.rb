class SellersController < ApplicationController
  before_action :authenticate_user!


  def dashboard
    @orders = Order.includes(:order_items).total_sellers_orders(current_user)
    @processing_orders = @orders.where(status: "processing")
  
   
    @recent_orders = @orders.order(created_at: :desc).limit(3).to_a

    respond_to do |format|
      format.html 
      format.js    
    end
  end

  def dashboard_filter
    orders = Order.includes(:order_items).total_sellers_orders(current_user)
    product_counts = {}

    if params[:start_date].present? || params[:end_date].present?
      start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
      end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    
      if start_date && end_date
        orders = orders.where('orders.created_at BETWEEN :start_date AND :end_date', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day)
      elsif start_date
        orders = orders.where('orders.created_at >= :start_date', start_date: start_date.beginning_of_day)
      elsif end_date
        orders = orders.where('orders.created_at <= :end_date', end_date: end_date.end_of_day)
      else
        orders = orders.all
      end
    else
      orders = orders.all
    end
    processing_count = orders.where(status: "processing").count
    total_sales = orders.where(status: "completed").sum(:total_amount)

    orders.all.each do |order|
      order.order_items.each do |item|
        product_name = item.product.category.name
        product_counts[product_name] ||= 0
        product_counts[product_name] += 1
      end
    end
    max_count = product_counts.values.max
    sorted_product_counts = product_counts.sort_by { |name, count| -count }.first(4)
    top_selling_products = Product.top_selling_products(3, current_user,start_date, end_date)
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

  def statistics
    @orders = Order.includes(:order_items).total_sellers_orders(current_user)
    @completed_orders = @orders.where(status: "completed")
    @todays_orders = @orders.where(created_at: Time.zone.today.all_day)
    @new_orders = @orders.where(status: "created")
    @processing_orders = @orders.where(status: "processing")
    @dispatched_orders = @orders.where(status: "dispatched")
    @max_orders_count = [@completed_orders.count, @new_orders.count, @dispatched_orders.count, @processing_orders.count].max
    @category_sales = {}
    @top_models = Category.monthly_category_sales_trends(current_user.id)

    @orders.all.each do |order|
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
  end

  def orders_list
    @orders_as_params = Order.includes(:order_items).joins(:buyer).total_sellers_orders(current_user)
    @orders = Order.includes(:order_items).joins(:buyer).total_sellers_orders(current_user).order(created_at: :desc)
    query_conditions = []
    query_params = {}
      if params[:order_status].present?
      query_conditions << 'orders.status = :order_status'
      query_params[:order_status] = params[:order_status]
    end
    if params[:date_filter].present?
      case params[:date_filter]
      when 'last-7-days'
        query_conditions << 'orders.created_at BETWEEN :start_date_7 AND :end_date'
        query_params[:start_date_7] = 7.days.ago
      when 'last-15-days'
        query_conditions << 'orders.created_at BETWEEN :start_date_15 AND :end_date'
        query_params[:start_date_15] = 15.days.ago
      when 'last-30-days'
        query_conditions << 'orders.created_at BETWEEN :start_date_30 AND :end_date'
        query_params[:start_date_30] = 30.days.ago
      when 'custom'
        if params[:start_date].present? && params[:end_date].present?
          query_conditions << 'orders.created_at BETWEEN :start_date AND :end_date'
          query_params[:start_date] = Date.parse(params[:start_date]).beginning_of_day
          query_params[:end_date] = Date.parse(params[:end_date]).end_of_day
        end
      end
      query_params[:end_date] ||= Time.now
    end
      if params[:search].present?
      query_conditions << '(users.email LIKE :search OR users.first_name LIKE :search OR users.last_name LIKE :search OR users.phone_number LIKE :search)'
      query_params[:search] = "%#{params[:search]}%"
    end
      if query_conditions.any?
      @orders = @orders.where(query_conditions.join(' AND '), query_params)
    end
    if params[:sort].present?
      sort_order = params[:sort] == 'oldest' ? :asc : :desc
      @orders = @orders.reorder(created_at: sort_order)
    end
    @orders = @orders.page(params[:page]).per(params[:per_page] || 8)
  
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update_order_status
    order = Order.find_by(id: params[:id])
    if order
      order.status = params[:status]
      if order.save
        redirect_to orders_list_path, notice: 'Order status updated successfully.'
      else
        redirect_to orders_list_path, errors: 'Failed to update the order status.'
      end
    else
      redirect_to orders_list_path, errors: 'Order not found.'
    end
  end

  def stats_filter
    sellers_orders = Order.includes(:order_items).total_sellers_orders(current_user)

    category_sales = {}
      if params[:start_date].present? || params[:end_date].present?
        start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
        end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
      
        if start_date && end_date
          date_orders = sellers_orders.where('orders.created_at BETWEEN :start_date AND :end_date', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day)
        elsif start_date
          orders = sellers_orders.where('orders.created_at >= :start_date', start_date: start_date.beginning_of_day)
        elsif end_date
          date_orders = sellers_orders.where('orders.created_at <= :end_date', end_date: end_date.end_of_day)
        else
          date_orders = sellers_orders
        end
      else
        date_orders = sellers_orders
      end
      new_count = date_orders.where(status: "created").count
      processing_count = date_orders.where(status: "processing").count
      completed_count = date_orders.where(status: "completed").count
      max_order_count = [new_count, processing_count, completed_count].max
      date_orders.all.each do |order|
        order.order_items.each do |item|
          quantity = item.quantity || 0
          price = item.price || 0.0
      
          category = item.product.category
          next unless category # Skip if no category is associated with the product
      
          category_id = category.id
          category_name = category.name
      
          category_sales[category_id] ||= { name: category_name, sales: 0 }
          category_sales[category_id][:sales] += quantity * price
        end
      end
      max_category_sales = category_sales.values.map { |v| v[:sales] }.max
      
      # Sorting by sales in descending order and taking the top 4
      sorted_category_sales = category_sales.map do |id, data|
        { id: id, name: data[:name], sales: data[:sales] }
      end.sort_by { |entry| -entry[:sales] }.first(4)
      top_selling_products = Product.top_selling_products(6,current_user,start_date, end_date )
      top_models = Category.monthly_category_sales_trends(current_user.id, start_date, end_date)

      render json: { 
        orders: date_orders, 
        new_count: new_count,
        processing_count: processing_count,
        completed_count: completed_count,
        max_order_count: max_order_count,
        max_category_sales: max_category_sales,
        sorted_category_sales: sorted_category_sales,
        top_selling_products:top_selling_products,
        top_model: top_models
      }, status: :ok

  end  



  def toggle_approve
    @order = Order.find_by(id: params[:id])
    if params[:approve] == 'true'
      @order.update(is_approve: true)
    elsif params[:approve] == 'false'
      @order.update(is_approve: false)
    end
    redirect_to orders_list_path, notice: "Order approval status updated."
  end
  

  def view_order_details
    @order = Order.find_by(id: params[:id])
  end

  def faq
  end

  def sellers_bids
    @bids = Bid.sellers_bids(current_user)
    @bids = @bids.where(status: params[:status]) if params[:status].present?
    @bids = @bids.order(created_at: :desc)
    if params[:sort].present?
      sort_column = params[:sort]
      sort_direction = params[:sort] == 'newest' ?  'desc' : 'asc'
      @bids = @bids.order(created_at:  sort_direction)
    end
    if params[:bids_status].present? 
      @bids = @bids.where(status: params[:bids_status].downcase )
    end
    if params[:start_date].present? && params[:end_date].present?
      @bids = @bids.where('bids.created_at >= ? AND bids.created_at <= ?', params[:start_date], params[:end_date])
    elsif params[:start_date].present?
      @bids = @bids.where('created_at >= ?', params[:start_date])
    elsif params[:end_date].present?
      @bids = @bids.where('created_at <= ?', params[:end_date])
    end
    @bids = @bids.page(params[:page]).per(params[:per_page] || 8)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def all_bids
    @bids = Bid.all
    @bids = @bids.page(params[:page]).per(params[:per_page] || 10)


  end


  def update_bid
    @bid = Bid.find_by(id: params[:bid_id])
    
    unless @bid.present?
      render json: { error: "Bid not found", redirect_url: "/bids" }, status: :not_found
      return
    end
    
    begin
      case params[:status]
      when "accept"
        inventory = Inventory.find_by(id: @bid.inventory_id)
        
        unless inventory
          render json: { error: "Inventory not found", redirect_url: "/bids" }, status: :unprocessable_entity
          return
        end
        
        # Check if there's enough stock - this is when we actually need to check
        # as bids don't reserve inventory until they're accepted
        if inventory.stock_quantity < @bid.quantity
          render json: { 
            error: "Not enough stock available. Required: #{@bid.quantity}, Available: #{inventory.stock_quantity}", 
            redirect_url: "/bids" 
          }, status: :unprocessable_entity
          return
        end
        
        # Create the order
        total_amount = @bid.accepted_price * @bid.quantity
        @order = Order.new(
          buyer_id: @bid.buyer_id, 
          status: "new", 
          total_amount: total_amount, 
          was_bid: true, 
          forwarder: @bid.forwarder
        )
        
        unless @order.save
          Rails.logger.error("Failed to create order: #{@order.errors.full_messages.join(', ')}")
          render json: { error: "Failed to create order", redirect_url: "/bids" }, status: :unprocessable_entity
          return
        end
        
        # Create order item
        @order_item = @order.order_items.new(
          inventory_id: @bid.inventory_id, 
          quantity: @bid.quantity, 
          price: @bid.accepted_price, 
          product_id: @bid.inventory.product.id
        )
        
        unless @order_item.save
          Rails.logger.error("Failed to create order item: #{@order_item.errors.full_messages.join(', ')}")
          @order.destroy # Rollback the order if we can't create the order item
          render json: { error: "Failed to create order item", redirect_url: "/bids" }, status: :unprocessable_entity
          return
        end
        
        # Update inventory and remove the bid
        inventory.update(stock_quantity: inventory.stock_quantity - @bid.quantity)
        @bid.destroy
        
        # Try to send emails, but don't fail if they don't work
        begin
          product_name = "#{@bid.inventory.product.name} #{@bid.inventory.product.variant}"
          
          NewOrderMailer.with(
            email: @bid.inventory.seller.email, 
            product_name: product_name, 
            quantity: @bid.quantity, 
            amount: @order.total_amount, 
            time: @order.created_at.strftime("%H:%M")
          ).new_order.deliver_now
          
          NewOrderMailer.with(
            email: @bid.buyer.email, 
            product_name: product_name, 
            quantity: @bid.quantity, 
            amount: @order.total_amount, 
            time: @order.created_at.strftime("%H:%M")
          ).buyer_new_order.deliver_now
        rescue => e
          Rails.logger.error("Failed to send order emails: #{e.message}")
          # Continue even if emails fail
        end
  
        if current_user.role == "seller"
          render json: { message: "Bid Accepted Successfully", redirect_url: "/orders-list" }, status: :ok
        else
          render json: { message: "Bid Accepted Successfully", redirect_url: "/my-orders" }, status: :ok
        end
      
      when "reject"
        @bid.update(status: "rejected")

        if current_user.role == "seller"
          render json: { message: "Bid rejected.", redirect_url: "/bids" }, status: :ok
        else
          render json: { message: "Bid rejected.", redirect_url: "/my-bids" }, status: :ok
        end
  
      when "negotiate"
        # Get the base price for validation
        inventory = @bid.inventory
        base_price = inventory.price
        offer_price = params[:price].to_f
        
        # Validate the price against base price
        if offer_price > base_price
          render json: { error: "Offer price cannot exceed the base price of #{ActionController::Base.helpers.number_to_currency(base_price, precision: 0)}", redirect_url: "/bids" }, status: :unprocessable_entity
          return
        end
        
        # Check if price is at least 95% of base price
        min_price = base_price * 0.95
        if offer_price < min_price
          render json: { error: "Offer price cannot be less than 95% of the base price", redirect_url: "/bids" }, status: :unprocessable_entity
          return
        end
        
        if @bid.update(offer_price: params[:price], accepted_price: params[:price], quoted_price: nil)
          begin
            product_name = "#{@bid.inventory.product.name} #{@bid.inventory.product.variant}"
            BidMailer.with(
              email: @bid.buyer.email,
              product_name: product_name,
              quantity: @bid.quantity,
              amount: @bid.offer_price
            ).new_counter.deliver_now
          rescue => e
            Rails.logger.error("Failed to send bid negotiation email: #{e.message}")
          end

          # Send WhatsApp counter-bid notification to buyer
          begin
            product_name ||= "#{@bid.inventory.product.name} #{@bid.inventory.product.variant}"
            WhatsappService.send_new_bid_notification(
              seller: @bid.buyer,
              product_name: product_name,
              quantity: @bid.quantity,
              amount: @bid.offer_price,
              time: Time.current.strftime("%H:%M")
            )
          rescue => e
            Rails.logger.error("Failed to send WhatsApp counter-bid notification to buyer #{@bid.buyer.id}: #{e.message}")
          end

          render json: { message: "Bid updated successfully.", redirect_url: "/bids" }, status: :ok
        else
          render json: { error: "Failed to update bid.", redirect_url: "/bids" }, status: :unprocessable_entity
        end
  
      when "buyer"
        # Get the base price for validation
        inventory = @bid.inventory
        base_price = inventory.price
        quoted_price = params[:price].to_f
        
        # Validate the price against base price
        if quoted_price > base_price
          render json: { error: "Bid price cannot exceed the base price of #{ActionController::Base.helpers.number_to_currency(base_price, precision: 0)}", redirect_url: "/my-bids" }, status: :unprocessable_entity
          return
        end
        
        # Check if price is at least 95% of base price
        min_price = base_price * 0.95
        if quoted_price < min_price
          render json: { error: "Bid price cannot be less than 95% of the base price", redirect_url: "/my-bids" }, status: :unprocessable_entity
          return
        end
        
        if @bid.update(quoted_price: params[:price], accepted_price: params[:price], offer_price: nil)
          begin
            product_name = "#{@bid.inventory.product.name} #{@bid.inventory.product.variant}"
            BidMailer.with(
              email: @bid.inventory.seller.email, 
              product_name: product_name, 
              quantity: @bid.quantity, 
              amount: @bid.quoted_price
            ).new_counter_seller.deliver_now
          rescue => e
            Rails.logger.error("Failed to send buyer counter-offer email: #{e.message}")
            # Continue even if email fails
          end
          
          render json: { message: "Bid updated successfully.", redirect_url: "/my-bids" }, status: :ok
        else
          render json: { error: "Failed to update bid.", redirect_url: "/my-bids" }, status: :unprocessable_entity
        end  
  
      else
        render json: { error: "Invalid status.", redirect_url: "/bids" }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error("Error in update_bid: #{e.message}")
      render json: { error: "An unexpected error occurred: #{e.message}", redirect_url: "/bids" }, status: :internal_server_error
    end
  end
  

  def devices
    brand_id = params[:brand_id]
    devices = Device.where(brand_id: brand_id)
    render json: devices.map { |d| { id: d.id, name: d.name, }}
  end

  def categories
    device_id = params[:device_id]
    categories = Category.where(device_id: device_id)
    render json: categories.map { |c| { id: c.id, name: c.name, }}
  end

  

  def products
  end

  def print_order
    @order = Order.find_by(id: params[:order])
  
    respond_to do |format|
      format.pdf do
        pdf = OrderPdf.new(@order, "Sales Order")
        send_data pdf.render,
                  filename: "sales-order-#{@order.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline' # Use 'attachment' for download
      end
    end
  end

  def products_details
    order = Order.find_by(id: params[:order_id]) if params[:order_id].present?
    if order.present?
      @order_details = order.order_product_details
    end
  end
  

  def upload_imei_sheet
    order_id = params[:order_id]
    if params[:file].present?
      result = OrderProductDetail.import_csv(params[:file],order_id.to_i )    
      if result[:errors].empty?
        redirect_to orders_list_path, notice: "Details uploaded successfully."
      else
        flash[:errors] = "Details upload completed with some issues:<br>#{result[:errors].join('<br>')}".html_safe
        redirect_to orders_list_path
      end
    else
      redirect_to products_inventories_path, alert: "Please upload a file."
    end
  end

  def sellers_brand_stats_devices
    brand_sales = {}
  
    brand = Brand.find_by(id: params[:id])
    
    if brand
      brand.devices.includes(products: { inventories: :order_items }).each do |device|
        device.products.each do |product|
          product.inventories.where(seller_id: current_user.id).each do |inventory|
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
      end.sort_by { |entry| -entry[:sales] }   
      end
    render json: {brand_sales: brand_sales, brand_name: brand.name}
  end

 def sellers_brand_stats_models
    models_sales = {}

    device = Device.find_by(name: params[:name], brand_id: params[:brand_id ])
    
    if device
      device.categories.includes(products: { inventories: :order_items }).each do |category|
        
        category.products.each do |product|
          
          product.inventories.where(seller_id: current_user.id).each do |inventory|
            
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
    render json: {models_sales: models_sales}
 end

 def sellers_brand_stats_products
  products_sales = {}

  category = Category.find_by(name: params[:name])

  if category
    category.products.each do |product|
      # Directly access the 'variant' attribute instead of using 'variants'
      product_variant = product.variant || "No variant"  # Using the 'variant' field directly

      product.inventories.where(seller_id: current_user.id).each do |inventory|
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
