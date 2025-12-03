# frozen_string_literal: true

module Page
  class ShowComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      show_header = {
        title: "iPhone 15 Pro",
        breadcrumbs: [
          { label: "Home", path: "/" },
          { label: "Products", path: "/products" },
          { label: "iPhone 15 Pro" }
        ],
        actions: [
          { label: "Edit", path: "#", style: :primary },
          { label: "Delete", path: "#", style: :danger }
        ]
      }

      show_overview = {
        title: "Product Details",
        items: [
          { label: "SKU", value: "APL-IP15P-256" },
          { label: "Category", value: "Electronics" },
          { label: "Price", value: "$1,199.00" },
          { label: "Stock", value: "42 units" },
          { label: "Status", value: "Active" }
        ]
      }

      render BetterPage::Page::ShowComponent.new(show_header: show_header, show_overview: show_overview)
    end

    # @label With Sections
    def with_sections
      show_header = {
        title: "Order #1001",
        metadata: [{ value: "Placed on Dec 1, 2024" }],
        actions: [{ label: "Print", path: "#", style: :secondary }]
      }

      show_overview = {
        title: "Order Details",
        items: [
          { label: "Status", value: "Completed" },
          { label: "Total", value: "$156.99" }
        ]
      }

      show_content_sections = [
        {
          title: "Customer Information",
          type: :details,
          items: [
            { label: "Name", value: "John Doe" },
            { label: "Email", value: "john@example.com" },
            { label: "Phone", value: "+1 (555) 123-4567" }
          ]
        },
        {
          title: "Shipping Address",
          type: :plain,
          content: "123 Main St, New York, NY 10001"
        }
      ]

      render BetterPage::Page::ShowComponent.new(
        show_header: show_header,
        show_overview: show_overview,
        show_content_sections: show_content_sections
      )
    end
  end
end
