class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  belongs_to :device
  belongs_to :brand


  validates_presence_of :name
  validates :name, uniqueness: { 
    scope: :device_id, 
    message: "of category should be unique per brand and device", 
    case_sensitive: false 
  }

  scope :with_available_inventory, ->(device_id) {
    where(device_id: device_id)
      .joins(products: :inventories)
      .where("inventories.stock_quantity > 0")
      .distinct
  }

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "name", "updated_at , brand_id, category_id"]
  end



  def self.monthly_category_sales_trends(user_id, start_date = nil, end_date = nil)
    start_date ||= 12.months.ago.beginning_of_month
    end_date ||= Time.current.end_of_month
    end_date = end_date.end_of_day 

    results = joins(products: { inventories: { order_items: :order } })
      .where(orders: { created_at: start_date..end_date })
      .where(inventories: { seller_id: user_id })
      .group(Arel.sql("TO_CHAR(orders.created_at, 'YYYY-MM'), categories.id, categories.name"))
      .order(Arel.sql("month ASC"))
      .pluck(Arel.sql("TO_CHAR(orders.created_at, 'YYYY-MM') AS month, 
                       categories.id, 
                       categories.name, 
                       SUM(order_items.quantity * order_items.price) AS total_sales"))

    chart_data = {}

    results.each do |month, category_id, category_name, total_sales|
      chart_data[category_name] ||= []
      chart_data[category_name] << { month: month, sales: total_sales.to_f }
    end

    chart_data
  end
end