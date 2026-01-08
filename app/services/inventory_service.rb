class InventoryService
  def self.create_or_update_inventory(params, seller_email=nil)
    # If seller_email is provided, use it, otherwise fall back to seller_id
    if seller_email
      seller = User.find_by(email: seller_email.downcase)
      return { success: false, message: "Seller not found for email: #{seller_email}" } if seller.nil?
    else
      seller = User.find_by(email: params[:seller_email])
      return { success: false, message: "Seller not found for ID: #{params[:seller_id]}" } if seller.nil?
    end

    product = Product.find_by(sku: params[:sku])
    return { success: false, message: "Product not found for SKU: #{params[:sku]}" } if product.nil?

    inventory = Inventory.find_or_initialize_by(seller: seller, product: product)
    if inventory.persisted?
      inventory.stock_quantity += params[:stock_quantity].to_i
      inventory.price = params[:price]
    else
      inventory.assign_attributes(
        stock_quantity: params[:stock_quantity],
        price: params[:price]
      )
    end

    if inventory.save
      { success: true, message: "Inventory #{inventory.persisted? ? 'updated' : 'created'} successfully for product '#{product.name}' and seller '#{seller.email}'." }
    else
      { success: false, message: "Failed to save inventory: #{inventory.errors.full_messages.join(', ')}" }
    end
  end
end
