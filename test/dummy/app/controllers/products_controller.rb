# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    products = Product.all.order(:name).to_a
    @page = Products::IndexPage.new(products).index
  end

  def show
    @page = Products::ShowPage.new(@product).show
  end

  def new
    product = Product.new
    @page = Products::NewPage.new(product).form
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
      @page = Products::NewPage.new(@product).form
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @page = Products::EditPage.new(@product).form
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      @page = Products::EditPage.new(@product).form
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: "Product was successfully deleted."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :active)
  end
end
