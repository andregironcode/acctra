class OrdersController < ApplicationController
  def create
    buyer_id = params[:order][:buyer_id] if params[:order][:buyer_id].present?
    forwarder = params[:order][:forwarder] if params[:order][:forwarder].present?

    unless params[:order_items].present?
      Rails.logger.error("Order items missing from request")
      render json: { success: false, error: "Order items cannot be empty" }, status: :unprocessable_entity
      return
    end

    # Get cart for the buyer to reference cart item quantities later
    cart = nil
    if buyer_id.present?
      cart = User.find_by(id: buyer_id)&.cart
    end

    items = Inventory.where(id: params[:order_items].pluck(:inventory_id))

    ActiveRecord::Base.transaction do
      begin
        # First clear the cart to restore inventory before checking stock
        # This ensures we're working with the correct stock levels
        clear_cart(buyer_id.to_i) if buyer_id.present? && cart.present?
        
        items.lock(true)
        items.group_by(&:seller_id).each do |seller_id, seller_items|
          # Filter order items to only include items for this seller
          seller_order_items = params[:order_items].select do |order_item_params|
            seller_items.any? { |item| item.id == order_item_params[:inventory_id].to_i }
          end
          
          # Skip if no items for this seller
          next if seller_order_items.empty?
          
          total_amount = calculate_total_amount(seller_order_items)

          order = Order.new(
            buyer_id: buyer_id,
            total_amount: total_amount,
            forwarder: forwarder
          )

          # Check stock and create order items only for this seller's items
          seller_order_items.each do |order_item_params|
            inventory = Inventory.find_by(id: order_item_params[:inventory_id])
            
            raise ActiveRecord::Rollback, "Inventory not found" unless inventory
            
            # Now check stock after cart has been cleared and inventory restored
            if inventory.stock_quantity.to_i < order_item_params[:quantity].to_i
              Rails.logger.error("Insufficient stock for inventory #{inventory&.product&.name}")
              raise ActiveRecord::Rollback, "Insufficient stock for inventory #{inventory&.product&.name}"
            end
          end

          # Save the order once per seller, not per item
          if order.save
            # Create order items for this seller only
            seller_order_items.each do |order_item_params|
              create_order_item(order_item_params, order.id)
            end
            send_order_notifications(order)
          else
            Rails.logger.error("Failed to create Order for seller_id: #{seller_id}")
            raise ActiveRecord::Rollback, "Failed to create Order"
          end
        end
        
        render json: { success: true }, status: :ok
      rescue ActiveRecord::Rollback => e
        Rails.logger.error("Order creation failed: #{e.message}")
        render json: { success: false, error: e.message }, status: :unprocessable_entity
      end
    end
  end

  def update_status
    Order.where(id: params[:order_ids]).update_all(status: 'processing')
    render json: { success: true }
  end

  private

  def calculate_total_amount(order_items)
    order_items.sum do |item|
      inventory = Inventory.find_by(id: item[:inventory_id])
      next 0 unless inventory

      item[:quantity].to_i * inventory.price
    end
  end

  def clear_cart(buyer_id)
    cart = User.find_by(id: buyer_id)&.cart
    cart&.destroy
  end

  def create_order_item(order_item_params, order_id)
    order_item_params = order_item_params.permit(:product_id, :quantity, :price, :inventory_id).merge(order_id: order_id)
    order_item = OrderItem.create(order_item_params)

    unless order_item.persisted?
      Rails.logger.error("Failed to create OrderItem for params: #{order_item_params}")
      raise ActiveRecord::Rollback, "Failed to create OrderItem"
    end
  end

  def send_order_notifications(order)
    seller = order.order_items.first.inventory.seller
    time = order.created_at.strftime("%H:%M")

    NewOrderMailer.with(
      email: seller.email, 
      order_items: order.order_items,
      amount: order.total_amount, 
      time: time
    ).new_order.deliver_now

    NewOrderMailer.with(
      email: order.buyer.email, 
      order_items: order.order_items,
      amount: order.total_amount, 
      time: time
    ).buyer_new_order.deliver_now
  end
end
