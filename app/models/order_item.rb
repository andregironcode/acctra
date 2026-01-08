class OrderItem < ApplicationRecord
    attr_accessor :skip_callbacks
    belongs_to :order
    belongs_to :product
    belongs_to :inventory
    validates :quantity, numericality: { greater_than: 0 }
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 1 }
    validate :validate_inventory_stock
    after_destroy :check_if_last_order_item_and_delete_order
    after_destroy :restore_inventory
    after_create :update_inventory_quantity

    private

    def check_if_last_order_item_and_delete_order
      # If this was the last order_item for the order, delete the order
      if order.order_items.count.zero?
        order.destroy
      end
    end
    
    def validate_inventory_stock
      return if skip_callbacks # Skip validation if flag is set
      return unless inventory
      if new_record? && quantity > inventory.stock_quantity
        errors.add(:quantity, "exceeds available stock (#{inventory.stock_quantity} available)")
      end
    end

    def update_inventory_quantity
      return if skip_callbacks # Skip callback if flag is set
      inventory.with_lock do
        # Double-check stock availability before reducing
        if inventory.stock_quantity >= self.quantity
          inventory.update!(stock_quantity: inventory.stock_quantity - self.quantity)
        else
          Rails.logger.error("Insufficient stock for #{product.name} - Required: #{self.quantity}, Available: #{inventory.stock_quantity}")
          # Will raise an error handled by the controller
          raise "Insufficient stock for #{product.name}"
        end
      end
    end

    def restore_inventory
      return if skip_callbacks # Skip callback if flag is set
      return unless inventory # Make sure inventory exists
      inventory.with_lock do
        inventory.update!(stock_quantity: inventory.stock_quantity + self.quantity)
      end
    end
  
    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "id", "id_value", "updated_at"]
    end
  end