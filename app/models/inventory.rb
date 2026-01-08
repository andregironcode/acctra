# app/models/inventory.rb
class Inventory < ApplicationRecord

  after_save :update_ranks_for_product

  belongs_to :seller, class_name: 'User'
  belongs_to :product
  has_many :order_items,dependent: :destroy
  has_many :cart_items,dependent: :destroy
  has_many :bids,dependent: :destroy

  # Validations
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "product_id", "seller_id", "stock_quantity", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["product", "seller"]
  end

  def self.search(query)
    return all if query.blank?
  
    joins(:product)
      .joins('LEFT JOIN brands ON brands.id = products.brand_id')
      .joins('LEFT JOIN devices ON devices.id = products.device_id')
      .where(
        'products.name ILIKE :query OR ' \
        'products.sku ILIKE :query OR ' \
        'products.variant ILIKE :query OR ' \
        'products.category_id IN (SELECT id FROM categories WHERE name ILIKE :query) OR ' \
        'brands.name ILIKE :query OR ' \
        'devices.name ILIKE :query OR ' \
        'inventories.stock_quantity::text ILIKE :query OR ' \
        'inventories.price::text ILIKE :query OR ' \
        'inventories.created_at::text ILIKE :query',
        query: "%#{query}%"
      )
  end

  def self.import_csv(file, seller_email=nil)
    successes = []
    errors = []
  
    CSV.foreach(file.path, headers: true).with_index(2) do |row, line_number|
      result = InventoryService.create_or_update_inventory(row.to_hash.symbolize_keys, seller_email)
      if result[:success]
        successes << "Line #{line_number}: #{result[:message]}"
      else
        errors << "Line #{line_number}: #{result[:message]}"
      end
    end
  
    { successes: successes, errors: errors }
  end

  private

  def update_ranks_for_product
    inventories = Inventory.where(product_id: product_id).order(:price)
    rank = 1
    previous_price = nil

    inventories.each_with_index do |inventory, index|
      if inventory.price == previous_price
        # If the price is the same as the previous, assign the same rank
        inventory.update_column(:rank, rank)
      else
        # Otherwise, assign the current rank and increment it
        rank = index + 1
        inventory.update_column(:rank, rank > 3 ? '3+' : rank)
        previous_price = inventory.price
      end
    end
  end

  def available_quantity
  stock_quantity - CartItem.where(inventory_id: id).sum(:quantity)
  end
end
