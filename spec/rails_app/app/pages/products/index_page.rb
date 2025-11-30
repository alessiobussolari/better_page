# frozen_string_literal: true

module Products
  class IndexPage < BetterPage::IndexBasePage
    def initialize(products, current_user = nil)
      @products = products
      @current_user = current_user
    end

    private

    def header
      {
        title: "Products",
        breadcrumbs: [
          { label: "Home", path: root_path },
          { label: "Products" }
        ],
        metadata: [
          { label: "Total", value: "#{@products.size} products" }
        ],
        actions: [
          { label: "New Product", path: new_product_path, icon: "plus", style: "primary" }
        ]
      }
    end

    def table
      {
        items: @products,
        columns: [
          { key: :id, label: "ID", type: :text },
          { key: :name, label: "Name", type: :link, path: ->(item) { product_path(item) } },
          { key: :formatted_price, label: "Price", type: :text },
          { key: :stock, label: "Stock", type: :text },
          { key: :status, label: "Status", type: :badge }
        ],
        actions: table_actions,
        empty_state: {
          icon: "inbox",
          title: "No products found",
          message: "Create your first product to get started.",
          action: { label: "New Product", path: new_product_path, icon: "plus" }
        }
      }
    end

    def table_actions
      lambda { |item|
        [
          { label: "View", path: product_path(item), icon: "eye", style: "secondary" },
          { label: "Edit", path: edit_product_path(item), icon: "edit", style: "secondary" }
        ]
      }
    end

    def statistics
      active_count = @products.count(&:active?)
      [
        { label: "Total", value: @products.size, icon: "box", color: "blue" },
        { label: "Active", value: active_count, icon: "check", color: "green" },
        { label: "Inactive", value: @products.size - active_count, icon: "x", color: "red" }
      ]
    end
  end
end
