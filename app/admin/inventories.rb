ActiveAdmin.register Inventory do
  controller do
    layout 'admin'

    def create
      result = InventoryService.create_or_update_inventory(
        seller_email: User.find(params[:inventory][:seller_id]).email,
        product_name: Product.find(params[:inventory][:product_id]).name,
        sku: Product.find(params[:inventory][:product_id]).sku,
        stock_quantity: params[:inventory][:stock_quantity],
        price: params[:inventory][:price]
      )
  
      if result[:success]
        redirect_to admin_inventories_path, notice: result[:message]
      else
        flash[:alert] = result[:message]
        redirect_back(fallback_location: admin_inventories_path)
      end
    end
  end

  permit_params :seller_id, :product_id, :stock_quantity, :price
  Formtastic::FormBuilder.perform_browser_validations = true


  action_item :bulk_upload, only: :index do
    link_to 'Bulk Upload Inventory', action: 'bulk_upload'
  end

  collection_action :bulk_upload, method: :get do
    render 'admin/inventories/bulk_upload'
  end

  collection_action :import_csv, method: :post do
    if params[:file].present?
      result = Inventory.import_csv(params[:file])
  
      if result[:errors].empty?
        redirect_to admin_inventories_path, notice: "Inventory uploaded successfully."
      else
        flash[:alert] = "Inventory upload completed with some issues:<br>#{result[:errors].join('<br>')}".html_safe
        redirect_to admin_inventories_path
      end
    else
      redirect_to admin_inventories_path, alert: "Please upload a file."
    end
  end
  
  index do
    selectable_column
    column :rank
    column 'Country' do |inventory|
      if inventory.product.country.present?
        if inventory.product.country.downcase == "europe"
          image_tag("europe.svg", width: 35, height: 35, alt: "Europe")
        else
          content_tag(:span, "", class: "flag flag-icon flag-icon-#{inventory.product.country.downcase} flag-icon-squared")
        end
      else
        "No flag"
      end
    end
    
    column :seller
    column :product
    column 'Variant' do |inventory|
      inventory.product.variant if inventory.product.variant
    end
    column ' SKU' do |inventory|
      inventory.product.sku if inventory.product.sku
    end
    column :stock_quantity
    column :price do |inventory|
      number_to_currency(inventory.price, precision: 0)
    end 
    actions defaults: false do |record|
      div class: 'dropdown' do
        button class: 'btn btn-primary dropdown-toggle',  type: 'button', data: { toggle: 'dropdown' } do
          'Actions'
        end
        ul class: 'dropdown-menu' do
          li do
            link_to 'View', admin_inventory_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Edit', edit_admin_inventory_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Delete', admin_inventory_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
          end
        end
      end
    end
  end

  filter :product_name_cont, label: 'Product Name', as: :string
  filter :product_id, label: 'Product', as: :select, collection: -> { Product.all.collect { |p| [p.name, p.id] } }

  filter :seller
  filter :stock_quantity

  form do |f|
    if f.object.new_record?
      render partial: 'admin/new_inventories_form', locals: { f: f }
    else
      render partial: 'admin/edit_inventories_form', locals: { f: f }
    end
  end

  collection_action :devices, method: :get do
    brand_id = params[:brand_id]
    devices = Device.where(brand_id: brand_id)
    render json: devices.map { |d| { id: d.id, name: d.name } }
  end

  collection_action :models, method: :get do
    device_id = params[:device_id]
    categories = Category.where(device_id: device_id)
    render json: categories.map { |c| { id: c.id, name: c.name, }}
  end

  collection_action :countries, method: :get do
    category_id = params[:category_id]
    products = Product.where(category_id: category_id.to_i)
    render json: products.map { |p| { country: p.country, category_id: category_id}}
  end

  collection_action :products, method: :get do
    country = params[:country]
    category_id= params[:category_id]
    products = Product.where(country: country, category_id: category_id.to_i)
    render json: products.map { |p| { id: p.id, name: p.name, sku: p.sku, variant: p.variant,  }}
  end

  csv do
    column :rank
    column('Country') { |inventory| inventory.product&.country || 'No flag' }
    column('Seller') { |inventory| inventory.seller.email }
    column('Product') { |inventory| inventory.product.name }
    column('Variant') { |inventory| inventory.product.variant }
    column('SKU') { |inventory| inventory.product.sku }
    column :stock_quantity
    column('Price') { |inventory| number_to_currency(inventory.price, precision: 0) }
  end
  

end


