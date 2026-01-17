namespace :import do
  desc "Import products from CSV file"
  task products: :environment do
    require 'csv'

    file_path = Rails.root.join('products_import.csv')

    unless File.exist?(file_path)
      puts "Error: File not found at #{file_path}"
      exit 1
    end

    errors = []
    success_count = 0
    brand_cache = {}
    device_cache = {}
    category_cache = {}

    puts "Starting product import from #{file_path}..."

    CSV.foreach(file_path, headers: true).with_index(2) do |row, line_number|
      product_data = row.to_hash

      brand_name = product_data['brand']
      device_name = product_data['device']
      category_name = product_data['category']
      product_name = product_data['name']
      sku = product_data['sku']
      variant = product_data['variant']
      country = product_data['country']
      model_number = product_data['model number']

      if brand_name.blank? || device_name.blank? || category_name.blank? || product_name.blank? || sku.blank? || variant.blank? || country.blank?
        errors << "Line #{line_number}: Missing required data"
        next
      end

      begin
        # Case-insensitive Brand lookup
        brand = brand_cache[brand_name.downcase] ||= Brand.where("LOWER(name) = ?", brand_name.downcase).first_or_create!(name: brand_name)

        # Case-insensitive Device lookup
        device_key = "#{brand.id}-#{device_name.downcase}"
        device = device_cache[device_key] ||= Device.where("LOWER(name) = ? AND brand_id = ?", device_name.downcase, brand.id).first_or_create!(name: device_name, brand_id: brand.id)

        # Case-insensitive Category lookup
        category_key = "#{device.id}-#{category_name.downcase}"
        category = category_cache[category_key] ||= Category.where("LOWER(name) = ? AND device_id = ?", category_name.downcase, device.id).first_or_create!(name: category_name, device_id: device.id, brand_id: brand.id)

        # Check if product with SKU already exists
        existing_product = Product.find_by("LOWER(sku) = ?", sku.downcase)
        if existing_product
          puts "Skipping duplicate SKU: #{sku}"
          next
        end

        # Create product
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

        if product.save
          success_count += 1
          puts "Created: #{product.name}" if success_count % 100 == 0
        else
          errors << "Line #{line_number}: #{product.errors.full_messages.join(', ')}"
        end
      rescue => e
        errors << "Line #{line_number}: #{e.message}"
      end
    end

    puts "\n" + "=" * 50
    puts "Import completed!"
    puts "Successfully imported: #{success_count} products"
    puts "Errors: #{errors.count}"

    if errors.any?
      puts "\nFirst 20 errors:"
      errors.first(20).each { |e| puts "  - #{e}" }
    end

    puts "\nSummary:"
    puts "  Brands: #{Brand.count}"
    puts "  Devices: #{Device.count}"
    puts "  Categories: #{Category.count}"
    puts "  Products: #{Product.count}"
  end
end
