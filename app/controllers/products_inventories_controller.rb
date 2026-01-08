class ProductsInventoriesController < ApplicationController
    before_action :set_inventory, only: [:edit, :update, :destroy]
    before_action :authenticate_user!
    before_action :check_permissions

  
    def index
      if current_user.present?
        @product_inventories = current_user.inventories
        .includes(product: [:brand, :device, :category])
        .where('stock_quantity > ?', 0)
        .order(updated_at: :desc)

        query_conditions = []
        query_params = {}
    
        if params[:brand].present?
          query_conditions << 'brands.name = :brand_name'
          query_params[:brand_name] = params[:brand]
        end
    
        if params[:device].present?
          query_conditions << 'devices.name = :device_name'
          query_params[:device_name] = params[:device]
        end
    
        if params[:category].present?
          query_conditions << 'categories.name = :category_name'
          query_params[:category_name] = params[:category]
        end
    
        if query_conditions.any?
          @product_inventories = @product_inventories
                                  .joins(product: [:brand, :device, :category])  # Ensure all tables are joined
                                  .where(query_conditions.join(' AND '), query_params)
        end
            if params[:search].present?
          @product_inventories = @product_inventories.search(params[:search])
        end
        @product_inventories = @product_inventories.page(params[:page]).per(params[:per_page] || 8)
    
        @brands = @product_inventories.map { |inventory| inventory.product.brand }.compact.uniq(&:id)
        @devices = @product_inventories.map { |inventory| inventory.product.device }.compact.uniq(&:id)
        @models = @product_inventories.map { |inventory| inventory.product.category }.compact.uniq(&:id)
      else
        @product_inventories = Inventory.none
      end
      if params[:category_id].present?
        @product_inventories = @product_inventories
        .joins(:product) # Join with the products table
        .where(products: { category_id: params[:category_id] })
        @product_inventories = @product_inventories.page(params[:page]).per(params[:per_page] || 8)
      end
      respond_to do |format|
        format.html
        format.js
      end
    end
  
    def new
      @inventory = Inventory.new
    end
    def create
      @inventory = Inventory.new(product_inventory_params)
  
      if @inventory.save
          flash[:notice]= 'Inventory was successfully created.'
        redirect_to products_inventories_path
      else
        render :new
      end
    end
  
    def destroy
      if  @inventory.destroy
        flash[:notice] = 'Product Inventory was successfully deleted.'
      else
        flash[:alert] = 'There was an issue deleting the Product Inventory. Please try again.'
      end
      redirect_to products_inventories_path
    end
  
    def edit
      @inventory = Inventory.find_by(id: params[:id])  
    end
  
    def update
      if  @inventory.update(product_inventory_params)
        flash[:notice] = 'Product Inventory was updated successfully.'
        redirect_to products_inventories_path
      else
        flash[:alert] = 'Failed to update the Product Inventory. Please fix the errors below.'
        render :edit
      end
    end

    def bulk_inventory_upload

      if params[:file].present?
        result = Inventory.import_csv(params[:file], current_user.email)    
        if result[:errors].empty?
          redirect_to products_inventories_path, notice: "Inventory uploaded successfully."
        else
          flash[:errors] = "Inventory upload completed with some issues:<br>#{result[:errors].join('<br>')}".html_safe
          redirect_to products_inventories_path
        end
      else
        redirect_to products_inventories_path, alert: "Please upload a file."
      end
    end
  
    private
  
    def set_inventory
      @inventory = Inventory.find_by(id: params[:id])
      unless @inventory
        flash[:alert] = "Inventory item not found."
        redirect_to products_inventory_path
      end
    end

    def check_permissions
      authorize! :manage, Inventory 
    end
  
    def product_inventory_params
      params.require(:inventory).permit(:seller_id, :product_id, :stock_quantity, :price, :seller_email, :product_name, :sku)
    end
  
end
