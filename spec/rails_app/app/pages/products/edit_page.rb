# frozen_string_literal: true

module Products
  class EditPage < FormBasePage
    def initialize(product, current_user = nil)
      @product = product
      @current_user = current_user
    end

    private

    def header
      {
        title: "Edit #{@product.name}",
        description: "Update product information.",
        breadcrumbs: [
          { label: "Home", path: root_path },
          { label: "Products", path: products_path },
          { label: @product.name, path: product_path(@product) },
          { label: "Edit" }
        ]
      }
    end

    def panels
      [
        {
          title: "Basic Information",
          description: "Update the product details",
          icon: "info",
          fields: [
            field_format(name: :name, type: :text, label: "Name", required: true, value: @product.name),
            field_format(name: :description, type: :textarea, label: "Description", value: @product.description),
            field_format(name: :price, type: :number, label: "Price", required: true, min: 0, step: 0.01, value: @product.price),
            field_format(name: :stock, type: :number, label: "Stock", min: 0, value: @product.stock)
          ]
        },
        {
          title: "Settings",
          description: "Product status",
          icon: "settings",
          fields: [
            field_format(name: :active, type: :checkbox, label: "Active", hint: "Enable to make product visible", checked: @product.active?)
          ]
        }
      ]
    end

    def footer
      {
        primary_action: { label: "Update Product", style: :primary, icon: "save" },
        secondary_actions: [
          { label: "Cancel", path: product_path(@product), style: :secondary }
        ]
      }
    end
  end
end
