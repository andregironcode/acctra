# app/models/cart_item.rb
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :inventory
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :check_inventory_availability
  
  after_create :reduce_inventory
  after_update :adjust_inventory
  after_destroy :restore_inventory
  
  def total_price
    inventory.price * quantity
  end

  private

  def check_inventory_availability
    return unless inventory
    if new_record?
      if quantity > inventory.stock_quantity
        errors.add(:quantity, "exceeds available stock (#{inventory.stock_quantity} available)")
      end
    else
      if quantity_changed? && quantity > inventory.stock_quantity + quantity_was
        errors.add(:quantity, "exceeds available stock")
      end
    end
  end

  def reduce_inventory
    inventory.with_lock do
      inventory.update!(stock_quantity: inventory.stock_quantity - quantity)
    end
  end

  def adjust_inventory
    if saved_change_to_quantity?
      old_quantity = quantity_before_last_save
      inventory.with_lock do
        inventory.update!(stock_quantity: inventory.stock_quantity + old_quantity - quantity)
      end
    end
  end

  def restore_inventory
    inventory.with_lock do
      inventory.update!(stock_quantity: inventory.stock_quantity + quantity)
    end
  end
end