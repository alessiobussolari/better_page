# frozen_string_literal: true

module Products
  class ShowPage < ShowBasePage
    def initialize(product, metadata = {})
      @product = product
      @user = metadata[:user]
      super(product, metadata)
    end

    private

    def header
      {
        title: @product.name,
        breadcrumbs: [
          { label: "Home", path: root_path },
          { label: "Products", path: products_path },
          { label: @product.name }
        ],
        metadata: [
          { label: "Status", value: @product.status },
          { label: "Price", value: @product.formatted_price }
        ],
        actions: [
          { label: "Edit", path: edit_product_path(@product), icon: "edit", style: "primary" },
          { label: "Delete", path: product_path(@product), icon: "trash", style: "danger", method: :delete, confirm: "Are you sure?" }
        ]
      }
    end

    def statistics
      [
        { label: "Price", value: @product.formatted_price, icon: "dollar", color: "green" },
        { label: "Stock", value: @product.stock, icon: "box", color: "blue" },
        { label: "Status", value: @product.status, icon: "tag", color: @product.active? ? "green" : "red" }
      ]
    end

    def content_sections
      [
        {
          title: "Product Details",
          icon: "info-circle",
          color: "blue",
          type: :info_grid,
          content: {
            "ID" => @product.id,
            "Name" => @product.name,
            "Price" => @product.formatted_price,
            "Stock" => @product.stock,
            "Status" => @product.status
          }
        },
        {
          title: "Description",
          icon: "document",
          color: "gray",
          type: :text_content,
          content: @product.description || "No description provided."
        }
      ]
    end
  end
end
