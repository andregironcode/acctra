ActiveAdmin.register Product do
  Formtastic::FormBuilder.perform_browser_validations = true
  controller do
    layout 'admin'
  end

  permit_params :name, :sku, :description, :price, :category_id, :seller_id, :brand_id, :device_id, :variant, :country, :model_number


  action_item :bulk_upload, only: :index do
    link_to 'Bulk Upload Product', action: 'bulk_upload'
  end

  collection_action :bulk_upload, method: :get do
    render 'admin/products/bulk_upload'
  end

  collection_action :import_csv, method: :post do
    if params[:file].present?
      errors = Product.import_csv(params[:file])
      if errors.empty?
        redirect_to admin_products_path, notice: "Product uploaded successfully."
      else
        flash[:alert] = "Products upload completed with some issues:<br>#{errors.join('<br>')}".html_safe
        redirect_to admin_products_path
      end
    else
      redirect_to admin_products_path, alert: "Please upload a file."
    end
  end

  index do
    selectable_column
    # id_column
    column :country do |product|
      if product.country.present?
        if product.country.downcase == 'europe'
          image_tag 'europe.svg', width: 35, height: 35, alt: 'Europe'
        else
          span class: "flag flag-icon flag-icon-#{product.country.downcase} flag-icon-squared"
        end
      else
        "No flag"
      end
    end
    
    column :name
    column :sku
    column :variant
    # column :price, sortable: :price do |product|
    #   "$#{product.price}"
    # end
    column "Category", :category
    column "Device", :device
    column "Brand", :brand
    column  :model_number
    
    # column :created_at
    actions defaults: false do |record|
      div class: 'dropdown' do
        button class: 'btn btn-primary dropdown-toggle',  type: 'button', data: { toggle: 'dropdown' } do
          'Actions'
        end
        ul class: 'dropdown-menu' do
          li do
            link_to 'View', admin_product_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Edit', edit_admin_product_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Delete', admin_product_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
          end
        end
      end
    end
  end

  filter :name
  filter :sku
  filter :variant
  # filter :price
  filter :category
  filter :seller
  filter :brand
  filter :device


  form partial: 'admin/new_products_form'

  # form do |f|
  #   f.inputs "Product Details" do
  #     f.input :name
  #     f.input :sku
  #     f.input :description
  #     f.input :variant
  #     f.input :category, as: :select, collection: Category.all.map { |c| [c.name, c.id] }
  #     f.input :device, as: :select, collection: Device.all.map { |c| [c.name, c.id] }
  #     f.input :brand, as: :select, collection: Brand.all.map { |c| [c.name, c.id] }
  #   end
  #   f.actions
  # end

  show do
    attributes_table do
      row :name
      row :sku
      row :model_number
      row :category
      row :brand
      row :device
      row :variant
      row :country do |product|
        if product.country.present?
          if product.country.downcase == 'europe'
            image_tag 'europe.svg', width: 35, height: 35, alt: 'Europe'
          else
            span class: "flag flag-icon flag-icon-#{product.country.downcase} flag-icon-squared"
          end
        else
          "No flag"
        end
      end
      
      row :created_at
      row :updated_at
    end
  end
end
