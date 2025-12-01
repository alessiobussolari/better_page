# frozen_string_literal: true

module Products
  class NewPage < FormBasePage
    def initialize(product, metadata = {})
      @product = product
      @user = metadata[:user]
      super(product, metadata)
    end

    private

    def header
      {
        title: "New Product",
        description: "Create a new product in your catalog.",
        breadcrumbs: [
          { label: "Home", path: root_path },
          { label: "Products", path: products_path },
          { label: "New" }
        ]
      }
    end

    def panels
      [
        {
          title: "Basic Information",
          description: "Enter the product details",
          icon: "info",
          fields: [
            { name: :name, type: :text, label: "Name", required: true, placeholder: "Product name" },
            { name: :description, type: :textarea, label: "Description", placeholder: "Product description" },
            { name: :price, type: :number, label: "Price", required: true, min: 0, step: 0.01 },
            { name: :stock, type: :number, label: "Stock", min: 0 }
          ]
        },
        {
          title: "Settings",
          description: "Product status",
          icon: "settings",
          fields: [
            { name: :active, type: :checkbox, label: "Active", hint: "Enable to make product visible" }
          ]
        }
      ]
    end

    def footer
      {
        primary_action: { label: "Create Product", style: :primary, icon: "plus" },
        secondary_actions: [
          { label: "Cancel", path: products_path, style: :secondary }
        ]
      }
    end
  end
end
