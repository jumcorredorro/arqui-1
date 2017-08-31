class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  def error(message,code,description)
    render status: code, json:{
      message:message,
      code:code,
      description: description
    }
  end
  # GET /products
  def index
    @products = Product.all
    count = Product.count
    if params[:firstResult] || params[:maxResult]
      if params[:firstResult] && !(Integer(params[:firstResult]) rescue false)
        error("Not Acceptable (Invalid Params)",406,"Attribute maxResult is not an Integer")
      elsif params[:firstResult] && (Integer(params[:firstResult])<=0 || Integer(params[:firstResult])>count)
        error("Not Acceptable (Invalid Params)",406,"Attribute maxResult is out of range")
      elsif params[:maxResult] && !(Integer(params[:maxResult]) rescue false)
        error("Not Acceptable (Invalid Params)",406,"Attribute maxResult is not an Integer")
      elsif params[:maxResult] && (Integer(params[:maxResult])>count || Integer(params[:maxResult])<=0)
        error("Not Acceptable (Invalid Params)",406,"Attribute maxResult is out of range")
      elsif params[:firstResult] && params[:maxResult]
        render json: {total:Integer(params[:maxResult])-Integer(params[:firstResult])+1,list:@products[Integer(params[:firstResult])-1,Integer(params[:maxResult])]}
      elsif params[:firstResult]
        render json: {total:count-Integer(params[:firstResult]),list:@products[Integer(params[:firstResult])-1,count]}
      elsif params[:maxResult]
        render json: {total:Integer(params[:maxResult]),list:@products[0,Integer(params[:maxResult])]}
      end
    else
      render json: {total:count,list:@products}
    end
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:name, :description, :price, :stock)
    end
end
