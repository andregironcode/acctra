class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    if params[:search].present?
      @products = Product.search(params[:search])
    else
      @products = Product.all
    end
  end

  def show
    @product = Product.find_by(id:params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Product was successfully destroyed.'
  end


  def fetch_products_countries
    category_id = params[:category_id]
    products = Product.where(category_id: category_id.to_i)
    render json: products.map { |p| { country: p.country, category_id: category_id}}


  end

  def fetch_products
    country = params[:country]
    category_id= params[:category_id]
    products = Product.where(country: country, category_id: category_id.to_i)
    render json: products.map { |p| { id: p.id, name: p.name, sku: p.sku, variant: p.variant,  }}
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :sku, :description)
  end
end
