class BuyersController < ApplicationController
  before_action :authenticate_user!

  def products
    @brands = Brand.with_available_inventory
    @forwarders = Forwarder.active.order(:name)
  end

  def fetch_devices
    brand_id = params[:brand_id]
    devices = Device.with_available_inventory(brand_id)
    render json: devices.map { |device| { id: device.id, name: device.name, icon: icon_name(device.name.downcase) } }
  end

  def fetch_categories
    device_id = params[:device_id]
    categories = Category.with_available_inventory(device_id)
    render json: categories.map { |c| { id: c.id, name: c.name } }
  end


  def fetch_products
    category_id = params[:category_id]
    inventories = Inventory.joins(:product)
          .where(products: { category_id: category_id })
          .where("inventories.stock_quantity > 0")
          .select("DISTINCT ON (products.sku) inventories.id, products.id AS product_id, products.name, products.sku, inventories.price, inventories.stock_quantity, products.variant, products.model_number")
          .order("products.sku, inventories.price ASC")
        
    products = inventories.group_by { |inv| inv.name }.map do |name, product_inventories|
      {
        name: name,
        sku: product_inventories.first.sku,
        inventories: product_inventories.map do |inv|
          {
            country: inv.product.country,
            price: inv.price,
            stock: inv.stock_quantity,
            variant: inv.product.variant
          }
        end
      }
    end
  
    render json: products
  end

  
  def fetch_inventories
      product_name = params[:product_name]
      inventories = Inventory.joins(:product)
      .where(products: { name: product_name }) 
      .where("inventories.stock_quantity > 0")
      .select("DISTINCT ON (products.sku) inventories.id, products.id AS product_id, products.name, products.sku, inventories.price, inventories.stock_quantity, products.variant, products.model_number")
      .order("products.sku, inventories.price ASC")
      render json: inventories.map { |inventory| 
      {
        id: inventory.product.id,    
        name: inventory.product.name,
        sku: inventory.product.sku,
        price: inventory.price,
        stock: inventory.stock_quantity,
        inventory_id: inventory.id,
        country: inventory.product.country,
        variant: inventory.product.variant,
        model_number: inventory.product.model_number,
      }
    }  
  end

  def cart
    @cart  = Cart.current_user_cart(current_user).first
    @forwarders = Forwarder.active.order(:name)
  end

  def add_to_cart
    ActiveRecord::Base.transaction do
      product = Product.find(params[:product_id])
      quantity = params[:quantity] || 1
      inventory_id = params[:inventory_id].to_i
      inventory = Inventory.lock.find_by(id: inventory_id)
      
      unless inventory && inventory.stock_quantity >= quantity.to_i
        render json: { error: 'Insufficient stock' }, status: :unprocessable_entity
        return
      end

      cart = current_user.cart || current_user.create_cart
      
      # Check if this item is already in the cart
      existing_cart_item = cart.cart_items.find_by(inventory_id: inventory.id)
      
      if existing_cart_item
        # If already in cart, just update the quantity
        new_quantity = existing_cart_item.quantity + quantity.to_i
        
        # Check if we have enough stock for the new total
        if new_quantity <= inventory.stock_quantity + existing_cart_item.quantity
          # The CartItem model will update inventory via callbacks, so don't update inventory here
          existing_cart_item.update!(quantity: new_quantity)
        else
          render json: { error: 'Insufficient stock for the requested quantity' }, status: :unprocessable_entity
          return
        end
      else
        # If not in cart, create a new cart item
        # The CartItem model will update inventory via callbacks, so don't update inventory here
        cart.cart_items.create!(product: product, quantity: quantity, inventory_id: inventory_id)
      end

      render json: { success: true, cart_count: cart.cart_items.count, category_id: product.category.id }
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update_cart_items
    ActiveRecord::Base.transaction do
      cart_item = CartItem.find_by(id: params[:cart_id])
      if cart_item
        inventory = Inventory.lock.find_by(id: cart_item.inventory.id)
        
        if params[:quantity].to_i <= 0
          # Let the CartItem model's after_destroy callback handle stock restoration
          cart_item.destroy
          render json: { message: 'Cart item deleted successfully' }, status: :ok
        else
          if params[:calculate] == "plus"
            if inventory.stock_quantity >= 1
              # Let the model's after_update callback handle inventory adjustment
              cart_item.update!(quantity: cart_item.quantity + 1)
              
              # Include inventory data in the response after reload
              inventory.reload
              render json: { 
                message: 'Cart updated successfully', 
                cart_item: cart_item.as_json.merge(inventory: { stock_quantity: inventory.stock_quantity }) 
              }, status: :ok
            else
              render json: { error: 'Insufficient stock' }, status: :unprocessable_entity
            end
          elsif params[:calculate] == "input"
            quantity_diff = params[:quantity].to_i - cart_item.quantity
            if quantity_diff > 0 && inventory.stock_quantity >= quantity_diff
              # Let the model's after_update callback handle inventory adjustment
              cart_item.update!(quantity: params[:quantity].to_i)
              
              # Include inventory data in the response after reload
              inventory.reload
              render json: { 
                message: 'Cart updated successfully', 
                cart_item: cart_item.as_json.merge(inventory: { stock_quantity: inventory.stock_quantity }) 
              }, status: :ok
            elsif quantity_diff < 0
              # Let the model's after_update callback handle inventory adjustment
              cart_item.update!(quantity: params[:quantity].to_i)
              
              # Include inventory data in the response after reload
              inventory.reload
              render json: { 
                message: 'Cart updated successfully', 
                cart_item: cart_item.as_json.merge(inventory: { stock_quantity: inventory.stock_quantity }) 
              }, status: :ok
            else
              render json: { error: 'Insufficient stock' }, status: :unprocessable_entity
            end
          else
            # Let the model's after_update callback handle inventory adjustment
            cart_item.update!(quantity: cart_item.quantity - 1)
            
            # Include inventory data in the response after reload
            inventory.reload
            render json: { 
              message: 'Cart updated successfully', 
              cart_item: cart_item.as_json.merge(inventory: { stock_quantity: inventory.stock_quantity }) 
            }, status: :ok
          end
        end
      else
        render json: { error: 'Cart item not found' }, status: :not_found
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def delete_item
    ActiveRecord::Base.transaction do
      cart_item = CartItem.find_by(id: params[:id])
      if cart_item
        inventory = Inventory.lock.find_by(id: cart_item.inventory.id)
        if inventory
          # Let the CartItem model's after_destroy callback handle stock restoration
          if cart_item.destroy
            render json: { 
              success: true, 
              message: 'Item was successfully deleted.',
              inventory_id: inventory.id,
              new_stock: inventory.reload.stock_quantity # Get the updated stock after model callback
            }, status: :ok
          else
            render json: { success: false, message: 'Item could not be deleted.' }, status: :unprocessable_entity
          end
        else
          render json: { success: false, message: 'Inventory not found.' }, status: :unprocessable_entity
        end
      else
        render json: { success: false, message: 'Item could not be deleted.' }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  

  def buyers_orders
    @orders = Order.where(buyer_id: current_user.id).order(created_at: :desc)
    @orders = @orders.page(params[:page]).per(params[:per_page] || 8)
  end

  def buyers_bids
    @bids = Bid.where(buyer_id: current_user.id)
  
    @bids = @bids.where(status: params[:status]) if params[:status].present?
  
    if params[:sort].present?
      sort_column = params[:sort]
      sort_direction = params[:sort] == 'newest' ?  'desc' : 'asc'
      @bids = @bids.order(created_at:  sort_direction)
    end
    if params[:bids_status].present? 
      @bids = @bids.where(status: params[:bids_status].downcase )
    end

    if params[:start_date].present? && params[:end_date].present?
      @bids = @bids.where('created_at >= ? AND created_at <= ?', params[:start_date], params[:end_date])
    elsif params[:start_date].present?
      @bids = @bids.where('created_at >= ?', params[:start_date])
    elsif params[:end_date].present?
      @bids = @bids.where('created_at <= ?', params[:end_date])
    end
    @bids = @bids.page(params[:page]).per(params[:per_page] || 7)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def consolidate_orders
    order_ids = params[:order_ids]
  
    orders = Order.where(id: order_ids)
    if orders.empty?
      render json: { error: "No orders found to consolidate" }, status: :unprocessable_entity
      return
    end
    
    # Get all sellers from the orders
    sellers = Set.new
    orders.each do |order|
      order.order_items.each do |item|
        if item.inventory&.seller_id
          sellers.add(item.inventory.seller_id)
        end
      end
    end
    
    # Check if orders are from multiple sellers
    if sellers.size > 1
      render json: { error: "Cannot consolidate orders from different sellers" }, status: :unprocessable_entity
      return
    end
    
    # Check if sellers is empty (no valid seller found)
    if sellers.empty?
      render json: { error: "No valid sellers found in the orders" }, status: :unprocessable_entity
      return
    end
    
    # Check for forwarder consistency
    forwarders = orders.map(&:forwarder).uniq.compact
    if forwarders.size > 1
      render json: { error: "Cannot consolidate orders with different forwarders" }, status: :unprocessable_entity
      return
    end
    
    # Check if orders were created on the same day
    created_dates = orders.map { |order| order.created_at.to_date }.uniq
    if created_dates.size > 1
      render json: { error: "Cannot consolidate orders created on different days" }, status: :unprocessable_entity
      return
    end
  
    consolidated_order = Order.new(
      buyer_id: orders.first.buyer_id,
      status: 'created',
      total_amount: 0,
      is_approve: false,
      was_bid: false,
      forwarder: orders.first.forwarder
    )
  
    consolidated_items = {}
    
    # Process each order, updating the consolidated items
    orders.each do |order|
      order.order_items.each do |order_item|
        inventory_id = order_item.inventory_id
        if consolidated_items[inventory_id]
          # Item already exists, just add the quantity
          consolidated_items[inventory_id][:quantity] += order_item.quantity
          consolidated_items[inventory_id][:total_price] += order_item.price * order_item.quantity
        else
          # New item, add it to the hash
          consolidated_items[inventory_id] = {
            product_id: order_item.product_id,
            quantity: order_item.quantity,
            total_price: order_item.price * order_item.quantity,
            price_per_unit: order_item.price,
          }
        end
      end
    end
  
    ActiveRecord::Base.transaction do
      # Create order items for the consolidated order
      consolidated_items.each do |inventory_id, item_data|
        price_per_unit = item_data[:price_per_unit]
        
        consolidated_order.order_items.build(
          product_id: item_data[:product_id],
          quantity: item_data[:quantity],
          price: price_per_unit,
          inventory_id: inventory_id,
          skip_callbacks: true
        )
      end
      
      # Calculate the total amount
      consolidated_order.total_amount = consolidated_items.values.sum { |item| item[:total_price] }
      
      # Save the consolidated order
      if consolidated_order.save
        # Before deleting original orders, mark their items to skip callbacks
        orders.each do |order|
          order.order_items.each { |item| item.skip_callbacks = true }
        end
        
        # Delete the original orders only if the consolidated order is saved successfully
        # The restore_inventory callback on original items will now be skipped
        orders.destroy_all
        
        render json: { message: "Orders consolidated successfully", order_id: consolidated_order.id }, status: :ok
      else
        # If save fails, raise an error to trigger the rescue block
        raise ActiveRecord::RecordInvalid.new(consolidated_order)
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
  
  
  def create_bid    
    inventory_id = params[:inventory_id]
    price = params[:quoted_price]
    quantity = params[:quantity]
    buyer_id = params[:buyer_id]
    
    # Find the inventory first
    inventory = Inventory.find_by(id: inventory_id)
    
    unless inventory
      render json: { error: 'Inventory not found' }, status: :unprocessable_entity
      return
    end
    
    # Validate the price against base price
    base_price = inventory.price
    quoted_price = price.to_f
    
    if quoted_price > base_price
      render json: { error: "Bid price cannot exceed the base price of #{ActionController::Base.helpers.number_to_currency(base_price, precision: 0)}" }, status: :unprocessable_entity
      return
    end
    
    # Check if price is at least 95% of base price
    min_price = base_price * 0.95
    if quoted_price < min_price
      render json: { error: "Bid price cannot be less than 95% of the base price" }, status: :unprocessable_entity
      return
    end
    
    # Check if there's enough stock (just a validation - we don't reduce stock for bids)
    if inventory.stock_quantity < quantity.to_i
      render json: { error: "Not enough stock available" }, status: :unprocessable_entity
      return
    end
    
    @bid = Bid.new(buyer_id: buyer_id, inventory_id: inventory_id, quantity: quantity, quoted_price: price, accepted_price: price, forwarder: params[:forwarder], alert: true)
   
    if @bid.save
      product = inventory.product
      product_string = "#{product.name} #{product.variant}"
      amount = "#{@bid.quoted_price.to_i}"
      quantity = "#{@bid.quantity}"
      render json: { success: true, redirect_url: "/my-bids" }, status: :ok
    else
      render json: { error: 'Unable to create bid' }, status: :unprocessable_entity
    end  
  end


  def print_order
    @order = Order.find_by(id: params[:order])

    respond_to do |format|
      format.pdf do
        pdf = OrderPdf.new(@order, "Purchase Order")
        send_data pdf.render,
                  filename: "purchase-order-#{@order.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline' 
      end
    end
  end

  def faq
  end
 
  private

  def icon_name(name)
    icon_mapping = {
      'mobile' => 'fa-mobile-screen',
      'mobiles' => 'fa-mobile-screen',
      'phones' => 'fa-mobile-screen',
      'laptop' => 'fa-laptop',
      'macbook' => 'fa-laptop',
      'headphone' => 'fa-headphones',
      'airpods' => 'fa-headphones',
      'handsfree' => 'fa-headphones',
      'iphone' => 'fa-mobile-screen',
      'mac' => 'fa-laptop',
    }
    icon = icon_mapping[name.downcase]

    unless icon
      icon || 'fa-question-circle' 
    end
    return icon
  end

end
