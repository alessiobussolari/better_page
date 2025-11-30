# frozen_string_literal: true

module Products
  class ShowPage < BetterPage::ShowBasePage
    def initialize(product, current_user = nil)
      @product = product
      @current_user = current_user
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
        statistic_format(label: "Price", value: @product.formatted_price, icon: "dollar", color: "green"),
        statistic_format(label: "Stock", value: @product.stock, icon: "box", color: "blue"),
        statistic_format(label: "Status", value: @product.status, icon: "tag", color: @product.active? ? "green" : "red")
      ]
    end

    def content_sections
      [
        content_section_format(
          title: "Product Details",
          icon: "info-circle",
          color: "blue",
          type: :info_grid,
          content: {
            "ID" => @product.id,
            "Name" => @product.name,
            "Price" => @product.formatted_price,
            "Stock" => @product.stock,
            "Status" => @product.status,
            "Created" => format_date(@product.created_at),
            "Updated" => format_date(@product.updated_at)
          }
        ),
        content_section_format(
          title: "Description",
          icon: "document",
          color: "gray",
          type: :text_content,
          content: @product.description || "No description provided."
        )
      ]
    end
  end
end
