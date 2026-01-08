class OrderProductDetail < ApplicationRecord
    belongs_to :order
    validates :imei, presence: true
  
    def self.import_csv(file, order_id)
      line_number = 0
      errors = []
      successful_records = []
    
      # Fetch valid SKUs from the order's order items
      valid_skus = OrderItem.where(order_id: order_id)
                      .includes(:product)
                      .pluck('products.sku')
                      .map(&:strip)

        CSV.foreach(file.path, headers: true) do |row|
          line_number += 1
          sku = row['sku']&.strip
          imei = row['imei']&.strip

          if sku.blank? || imei.blank?
            errors << "Error on line #{line_number}: SKU or IMEI is missing"
            next
          end

          unless valid_skus.include?(sku)
            errors << "Error on line #{line_number}: SKU '#{sku}' is not associated with the order"
            next
          end
      
    
        existing_record = self.find_by(order_id: order_id, sku: sku, imei: imei)
        if existing_record
          errors << "Error on line #{line_number}: SKU '#{sku}' and IMEI '#{imei}' already exists"
          next
        end
    
        begin
          new_record = self.create!(
            order_id: order_id,
            sku: sku,
            imei: imei
          )
          successful_records << new_record
        rescue => e
          errors << "Error on line #{line_number}: Could not create order product detail with SKU '#{sku}' and IMEI '#{imei}'. Error: #{e.message}"
        end
      end
    
      { errors: errors, successful_records: successful_records }
    end
    
  end
  