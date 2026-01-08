ActiveAdmin.register Order do
    actions :all, :except => [:new, :create]

    controller do
      layout 'admin'

      def destroy
        order = Order.find(params[:id])
  
        begin
          # Use destroy! which triggers dependent: :destroy and callbacks
          order.destroy!
          flash[:notice] = "Order ##{order.id} was successfully deleted, and stock quantities were updated."
        rescue => e
          flash[:error] = "Failed to delete order: #{e.message}"
        ensure
          redirect_to admin_orders_path
        end
      end
      
      def csv_filename
        "orders-#{Time.zone.now.strftime("%Y-%m-%d")}.csv"
      end

      def index
        super do |format|
          format.xml { render xml: collection.to_xml(include: {order_items: {include: {inventory: {include: :seller}}}}, methods: [:buyer_name, :seller_names], except: []) }
          format.json { render json: collection.to_json(include: {order_items: {include: {inventory: {include: :seller}}}}, methods: [:buyer_name, :seller_names]) }
          yield(format) if block_given?
        end
      end
    end
    permit_params :buyer_id, :total_amount, :status, :forwarder, order_items_attributes: [:id, :product_id, :quantity, :price, :_destroy, :inventory_id]

    scope :all
    scope("New") { |scope| scope.where(status: :created) }
    scope :processing
    scope :completed
    
    
    filter :buyer
    filter :status
    filter :total_amount
    filter :created_at, label: "Date"
    
    index do
      selectable_column
      column "Order No#" do |order|
      "##{order.id}"
      end

      column :buyer
      column "Seller(s)" do |order|
        sellers = order.order_items.includes(inventory: :seller).map do |item|
          if item.inventory&.seller
            link_to item.inventory.seller.full_name, admin_user_path(item.inventory.seller.id)
          end
        end.compact.uniq
        
        if sellers.any?
          sellers.join(", ").html_safe
        else
          "No seller found"
        end
      end
      column :status do |order|
        status_tag order.status, class: "order-#{order.status}"
      end
      # column :is_approve
      column :was_bid
      column :total_amount do |order|
        number_to_currency(order.total_amount, precision: 0)
      end   
      actions defaults: false do |record|
        div class: 'dropdown' do
          button class: 'btn btn-primary dropdown-toggle',  type: 'button', data: { toggle: 'dropdown' } do
            'Actions'
          end
          ul class: 'dropdown-menu' do
            li do
              link_to 'View', admin_order_path(record), class: 'dropdown-item'
            end
            li do
              link_to 'Delete', admin_order_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
            end
            li do
              link_to 'Print Order', print_order_admin_order_path(record, format: :pdf), target: '_blank', class: 'dropdown-item'
            end
          end
        end
      end
    end
    show do
      attributes_table do
        row :buyer
        row :forwarder
        row :status do |order|
          order.status == "created" ? "New" : order.status.capitalize
        end
        # row :is_approve
        row :was_bid
        row :total_amount
        row "Date time" do |order|
          order.created_at
        end
      end
    
      panel "Products Details" do
        table_for order.order_items do

          column "Seller" do |order_item|
            if order_item.inventory&.seller
              link_to order_item.inventory.seller.full_name, admin_user_path(order_item.inventory.seller.id), style: "text-decoration: underline;"
            end
          end

          column "Inventory" do |order_item|
            if order_item.inventory
              link_to "Inventory", admin_inventory_path(order_item.inventory.id), style: "text-decoration: underline;"
            end
          end

          column "Product" do |order_item|
            if order_item.inventory
              link_to order_item.product.name, admin_product_path(order_item.product.id), style: "text-decoration: underline;"
            end
          end
          column "Brand" do |order_item|
            order_item.product.brand.name if order_item.product.brand
          end

          column "Device" do |order_item|
            order_item.product.brand.name if order_item.product.device
          end
          column "Category" do |order_item|
            order_item.product.category.name if order_item.product.category
          end
          column :quantity
          column :price do |order_item|
            number_to_currency(order_item.price, precision: 0)
          end 
          column :total do |order_item|
            number_to_currency(order_item.quantity * order_item.price , precision: 0)
          end
        end
        div class: 'd-flex justify-content-end pr-4 ' do
          h5 "Total: #{number_to_currency(order.order_items.sum { |item| item.quantity * item.price }, precision: 0)}"
        end
      end
    end
    


 
    form do |f|
      f.semantic_errors # Display errors for the form
      f.inputs 'Order Details' do
        f.input :status
        f.input :buyer, as: :select, collection: User.all, prompt: "Select a Buyer"
        f.input :forwarder
        f.input :total_amount, input_html: { id: 'order_total_amount', readonly: true }
      end
    
      f.inputs 'Order Items' do
        f.has_many :order_items, allow_destroy: false, new_record: false do |item_f|
          item_f.input :product_id, as: :select, collection: Product.all.pluck(:name, :id), input_html: { disabled: true }
          item_f.input :quantity, input_html: { class: 'order-item-quantity' }
          item_f.input :price, input_html: { class: 'order-item-price', min: 1 }
        end
      end
    
      f.actions
    end
    
      member_action :print_order, method: :get do
        order = Order.find(params[:id])
    
        respond_to do |format|
          format.pdf do
            pdf = OrderPdf.new(order, "Sales Order")
            send_data pdf.render,
                      filename: "sales-order-#{order.id}.pdf",
                      type: 'application/pdf',
                      disposition: 'inline' # Use 'attachment' for download
          end
        end      
      end     
       
  # Configure CSV, XML, and JSON exports to include buyer and seller names
  csv do
    column :id
    column("Buyer") { |order| order.buyer&.full_name }
    column("Seller(s)") do |order|
      order.order_items.includes(inventory: :seller).map do |item|
        item.inventory&.seller&.full_name
      end.compact.uniq.join(", ")
    end
    column :forwarder
    column :status
    column :was_bid
    column("Total Amount") { |order| number_to_currency(order.total_amount, precision: 0) }
    column :created_at
  end

end
