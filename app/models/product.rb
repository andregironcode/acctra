class Product < ApplicationRecord
  belongs_to :category
  belongs_to :brand
  belongs_to :device
  has_many :inventories, dependent: :destroy
  has_many :sellers, through: :inventories, source: :seller
  has_many :order_items,dependent: :destroy


  validates :name, :sku, presence: true
  validates_uniqueness_of :sku, case_sensitive: false
  # validates :price, numericality: { greater_than_or_equal_to: 0, message: "must be a positive amount" }
  before_save :clean_name



  def self.ransackable_attributes(auth_object = nil)
    ["category", "brand", "device", "variant", "created_at", "description", "id", "id_value", "name", "price", "seller_id", "sku", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["category",  "brand" , "device"]
  end

  def self.search(query)
    return all if query.blank?
    joins(:category)
      .where(
        'products.name ILIKE :query OR products.sku ILIKE :query OR categories.name ILIKE :query',
        query: "%#{query}%"
      )
  end

  def self.top_selling_products(limit = 3, user = nil, start_date = nil, end_date = nil)
    if start_date.present?
      start_date = start_date.beginning_of_day
      end_date ||= Time.current.end_of_day
      end_date = end_date.end_of_day
    end
  
    query = joins(inventories: :order_items)  # Join inventories and order_items directly
            .joins('INNER JOIN orders ON orders.id = order_items.order_id')  # Join orders to filter by date
            .select('products.id, products.name, products.variant, products.country, 
                     SUM(order_items.quantity * order_items.price) AS total_sales, 
                     SUM(order_items.quantity) AS total_quantity_sold')
            .group('products.id, products.name, products.variant, products.country')  
            .order('total_sales DESC') 
            .limit(limit)
  
    query = query.where(inventories: { seller_id: user.id }) if user.present?
    query = query.where('orders.created_at BETWEEN ? AND ?', start_date, end_date) if start_date.present?
  
    query
  end
  
  
  


  def self.import_csv(file)
    errors = []
    brand_cache = {}
    device_cache = {}
    category_cache = {}
  
    # Open CSV file and process each row
    CSV.foreach(file.path, headers: true).with_index(2) do |row, line_number|
      product_data = row.to_hash
  
      # Ensure the required fields are present
      brand_name = product_data['brand']
      device_name = product_data['device']
      category_name = product_data['category']
      product_name = product_data['name']
      sku = product_data['sku']
      variant = product_data['variant']
      country = product_data['country']
      model_number = product_data['model number']
  
      if brand_name.blank? || device_name.blank? || category_name.blank? || product_name.blank? || sku.blank? || variant.blank? || country.blank?
        errors << "Missing required data on line #{line_number}: One or more fields are blank"
        next
      end
  
      # Case-insensitive Brand lookup
      brand = brand_cache[brand_name.downcase] ||= Brand.where("LOWER(name) = ?", brand_name.downcase).first_or_create(name: brand_name)
      
      # Case-insensitive Device lookup, ensuring it belongs to the correct brand
      device = device_cache[device_name.downcase] ||= Device.where("LOWER(name) = ?", device_name.downcase).find_or_create_by(name: device_name, brand_id: brand.id)
      if device.new_record?
        errors << "Error creating device on line #{line_number}: Device '#{device_name}' could not be created"
        next
      end
  
      # Case-insensitive Category lookup, ensuring it belongs to the correct device
      category = category_cache[category_name.downcase] ||= Category.where("LOWER(name) = ?", category_name.downcase).find_or_create_by(name: category_name, device_id: device.id, brand_id: brand.id)
      if category.new_record?
        errors << "Error creating category on line #{line_number}: Category '#{category_name}' could not be created"
        next
      end
  
      # Create product instance
      product = Product.new(
        name: product_name,
        sku: sku,
        variant: variant,
        country: country,
        brand_id: brand.id,
        device_id: device.id,
        category_id: category.id,
        model_number: model_number
      )
  
      # Save product or collect errors
      if product.save
        puts "Product created: #{product.name}"
      else
        errors << "Error creating product on line #{line_number}: #{product.errors.full_messages.join(', ')}"
      end
    end
  
    # Return any errors encountered during import
    errors
  end

  private

  def clean_name
    if name.present?
      name.strip! # Remove leading/trailing spaces
      self.name = name.gsub("'", '"') if name.present?
    end
  end
  
  
  
  

end
