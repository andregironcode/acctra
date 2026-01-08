class Device < ApplicationRecord
    has_many :products, dependent: :destroy
    has_many :categories, dependent: :destroy
    belongs_to :brand

    validates_presence_of :name
    validates :name, uniqueness: { 
      scope: :brand_id, 
      message: "of device should be unique per brand", 
      case_sensitive: false 
    }

    scope :with_available_inventory, ->(brand_id) {
      where(brand_id: brand_id)
        .joins(products: :inventories)
        .where("inventories.stock_quantity > 0")
        .distinct
    }
        
    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "id", "id_value", "name", "brand_id", "updated_at"]
    end

    def self.ransackable_associations(auth_object = nil)
      ["brands"]
    end


end
