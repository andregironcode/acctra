class OrderPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper

  
  def initialize(order, type)
    super()
    @order = order
    generate_pdf(type)
  end

  def generate_pdf(type)
    text type, size: 24, style: :bold, align: :center
    move_down 15

    add_logo
    add_company_info
    move_down 20

    bounding_box([0, cursor], width: bounds.width) do
      formatted_text = [
        { text: "Order Date: #{@order.created_at.strftime('%d-%m-%Y')}", size: 14, styles: [:bold] },
        { text: "Order No: ##{@order.id}", size: 14, styles: [:bold] }
      ]

      text_box formatted_text[0][:text],
               at: [0, cursor],
               size: formatted_text[0][:size],
               style: formatted_text[0][:styles],
               width: bounds.width / 2,
               align: :left

      text_box formatted_text[1][:text],
               at: [bounds.width / 2, cursor],
               size: formatted_text[1][:size],
               style: formatted_text[1][:styles],
               width: bounds.width / 2,
               align: :right
    end

    move_down 40

    if @order.order_items.any?
      table order_items_table, header: true, position: :center, width: bounds.width do
        row(0).font_style = :bold
        self.header = true
        cells.size = 6
      end

      move_down 20

      total_amount = @order.order_items.sum { |item| item.price * item.quantity }
      text "Total Amount: $#{number_with_delimiter(total_amount, delimiter: ',')}", size: 14, style: :bold, align: :right
    else
      text "No items in this order.", align: :center, size: 12
    end

    move_down 50

    add_forwarder_info

    # Check if there are any product details with IMEIs to display
    if @order.order_product_details.any?
      start_new_page
      add_product_details_page
    end
  end

  def add_logo
      default_image_path = Rails.root.join("app/assets/images/logo.jpg")
      image default_image_path, width: 75, position: :center
  end
  
  def add_product_details_page
    text "Product Details", size: 24, style: :bold, align: :center
    move_down 15
    
    # Add a smaller version of the company info and order number
    text "Order No: ##{@order.id}", size: 14, style: :bold, align: :center
    move_down 30
    
    # Group order product details by SKU
    grouped_details = @order.order_product_details.group_by(&:sku)
    
    if grouped_details.any?
      grouped_details.each do |sku, details|
        # Find the product associated with this SKU
        product = Product.find_by(sku: sku)
        product_name = product ? "#{product.name} #{product.variant}" : "Unknown Product"
        
        # Create a section for each product
        text "Product: #{product_name}", size: 14, style: :bold
        text "SKU: #{sku}", size: 12
        move_down 10
        
        # Create a table for the IMEIs of this product
        imei_data = [["No.", "IMEI"]]
        details.each_with_index do |detail, index|
          imei_data << [index + 1, detail.imei]
        end
        
        table imei_data, header: true, position: :center, width: bounds.width / 2 do
          row(0).font_style = :bold
          self.header = true
          cells.size = 10
        end
        
        move_down 30
      end
    else
      text "No product details available for this order.", align: :center, size: 12, style: :italic
    end
  end

  def add_company_info
    move_down 20

    text "Sunwin Trading FZCO", size: 14, style: :bold, align: :center
    move_down 8
    text "Address - Warehouse H13 , Dubai Airport Free zone , Dubai , UAE ", size: 12, align: :center
    move_down 8
    text "Tel - +9714 2280800" , size: 12, align: :center, size: 12, align: :center
    move_down 8

    text"email - info@sunwin.ae", size: 12, align: :center, size: 12, align: :center
    move_down 20
  end

  def add_forwarder_info
    text "Forwarder Details", size: 14, style: :bold, align: :left
    move_down 10

    if @order.forwarder
      text "Name: #{@order.forwarder}", size: 12, align: :left
    else
      text "No forwarder details available.", size: 12, style: :italic, align: :left
    end
  end

  def add_addresses
    bounding_box([0, cursor], width: bounds.width) do
      formatted_text_box(
        [
          { text: "Seller\n\n", styles: [:bold], size: 12 },
          { text: "#{@order.order_items.first.inventory.seller.address}\n", styles: [:italic], size: 12 },
          { text: "#{@order.order_items.first.inventory.seller.email}\n", styles: [:italic], size: 12 }
        ],
        at: [0, cursor],
        width: bounds.width / 2
      )
      
      formatted_text_box(
        [
          { text: "Buyer\n\n", styles: [:bold], size: 12 },
          { text: "#{@order.buyer.address}\n", styles: [:italic], size: 12 },
          { text: "#{@order.buyer.email}\n", styles: [:italic], size: 12 }
        ],
        at: [bounds.width / 2, cursor],
        width: bounds.width / 2,
        align: :right
      )
    end
  end

  def order_items_table
    [["Number", "COUNTRY", "BRAND", "NAME OF ITEM + VARIANT","MODEL NO","QTY", "UNIT PRICE",  "AMOUNT"]] +
      @order.order_items.each_with_index.map do |item, index|
        brand = Brand.find_by(id: item.product.brand_id)&.name || "-" # Ensure it's a string
  
        [
          index + 1,
          item.product.country || "-",
          brand,
          item.product.name + ","+item.product.variant,
          item.product.model_number.present? ? item.product.model_number : "-",
          item.quantity,
          "$#{item.price.to_i}",
          "$#{number_with_delimiter(item.price.to_i * item.quantity)}"
        ]
      end
  end
end
