# frozen_string_literal: true

module Page
  class IndexComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    # Complete index page with header and table
    def default
      header = {
        title: "Products",
        breadcrumbs: [
          { label: "Home", path: "/" },
          { label: "Products" }
        ],
        actions: [
          { label: "Export", path: "#", style: :secondary },
          { label: "New Product", path: "#", style: :primary }
        ]
      }

      table = {
        enabled: true,
        items: [
          { id: 1, name: "iPhone 15", price: 999.00, stock: 50, status: true },
          { id: 2, name: "MacBook Pro", price: 2499.00, stock: 25, status: true },
          { id: 3, name: "AirPods Pro", price: 249.00, stock: 100, status: false }
        ],
        columns: [
          { key: :name, label: "Product" },
          { key: :price, label: "Price", format: :currency },
          { key: :stock, label: "Stock" },
          { key: :status, label: "Active", format: :boolean }
        ]
      }

      render BetterPage::Page::IndexComponent.new(header: header, table: table)
    end

    # @label With Search
    def with_search
      header = {
        title: "Users",
        actions: [{ label: "Add User", path: "#", style: :primary }]
      }

      search = {
        enabled: true,
        placeholder: "Search users...",
        current_search: nil,
        filters: [
          { name: :role, label: "Role", type: :select, options: [["All", ""], ["Admin", "admin"], ["User", "user"]] }
        ]
      }

      table = {
        enabled: true,
        items: [
          { id: 1, name: "John Doe", email: "john@example.com", role: "Admin" },
          { id: 2, name: "Jane Smith", email: "jane@example.com", role: "User" }
        ],
        columns: [
          { key: :name, label: "Name" },
          { key: :email, label: "Email" },
          { key: :role, label: "Role" }
        ]
      }

      render BetterPage::Page::IndexComponent.new(header: header, search: search, table: table)
    end

    # @label With Statistics
    def with_statistics
      header = { title: "Dashboard" }

      statistics = [
        { label: "Total Users", value: "1,234", change: "+12%", trend: :up },
        { label: "Revenue", value: "$45,678", change: "+8%", trend: :up },
        { label: "Orders", value: "856", change: "-3%", trend: :down },
        { label: "Conversion", value: "3.2%", change: "+0.5%", trend: :up }
      ]

      table = {
        enabled: true,
        items: [
          { id: 1, name: "Recent Order #1001", total: "$125.00", status: "Completed" },
          { id: 2, name: "Recent Order #1002", total: "$89.50", status: "Pending" }
        ],
        columns: [
          { key: :name, label: "Order" },
          { key: :total, label: "Total" },
          { key: :status, label: "Status" }
        ]
      }

      render BetterPage::Page::IndexComponent.new(header: header, statistics: statistics, table: table)
    end

    # @label With Pagination
    def with_pagination
      header = { title: "Products" }

      table = {
        enabled: true,
        items: (1..10).map { |i| { id: i, name: "Product #{i}", price: (i * 10.99).round(2) } },
        columns: [
          { key: :name, label: "Name" },
          { key: :price, label: "Price", format: :currency }
        ]
      }

      pagination = {
        enabled: true,
        current_page: 3,
        total_pages: 10,
        start_record: 51,
        end_record: 75,
        total_records: 248
      }

      render BetterPage::Page::IndexComponent.new(header: header, table: table, pagination: pagination)
    end
  end
end
