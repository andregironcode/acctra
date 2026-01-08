class Brand < ApplicationRecord
    has_many :products, dependent: :destroy
    has_many :devices, dependent: :destroy
    has_many :categories, dependent: :destroy

    validates_presence_of :name
    validates_uniqueness_of :name, case_sensitive: false
    scope :with_available_inventory, -> { joins(products: :inventories).where("inventories.stock_quantity > 0").distinct }

    
    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "id", "id_value", "name", "updated_at"]
    end
end
