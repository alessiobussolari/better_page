# frozen_string_literal: true

class TableComponentPreview < ViewComponent::Preview
  # @label Default
  # Basic table with items and columns
  def default
    items = [
      { id: 1, name: "iPhone 15", price: 999.00, stock: 50 },
      { id: 2, name: "MacBook Pro", price: 2499.00, stock: 25 },
      { id: 3, name: "AirPods Pro", price: 249.00, stock: 100 }
    ]

    columns = [
      { key: :name, label: "Product" },
      { key: :price, label: "Price", format: :currency },
      { key: :stock, label: "Stock" }
    ]

    render BetterPage::Ui::TableComponent.new(items: items, columns: columns)
  end

  # @label With Row Actions
  # Table with edit and delete actions for each row
  def with_row_actions
    items = [
      { id: 1, name: "iPhone 15", price: 999.00, status: true },
      { id: 2, name: "MacBook Pro", price: 2499.00, status: true },
      { id: 3, name: "iPad Air", price: 599.00, status: false }
    ]

    columns = [
      { key: :name, label: "Product" },
      { key: :price, label: "Price", format: :currency },
      { key: :status, label: "Active", format: :boolean }
    ]

    row_actions = ->(item) {
      [
        { label: "Edit", path: "#edit-#{item[:id]}", style: :primary },
        { label: "Delete", path: "#delete-#{item[:id]}", style: :danger, confirm: "Are you sure?" }
      ]
    }

    render BetterPage::Ui::TableComponent.new(
      items: items,
      columns: columns,
      row_actions: row_actions
    )
  end

  # @label Selectable
  # Table with checkboxes for row selection
  def selectable
    items = [
      { id: 1, name: "User 1", email: "user1@example.com" },
      { id: 2, name: "User 2", email: "user2@example.com" },
      { id: 3, name: "User 3", email: "user3@example.com" }
    ]

    columns = [
      { key: :name, label: "Name" },
      { key: :email, label: "Email" }
    ]

    render BetterPage::Ui::TableComponent.new(
      items: items,
      columns: columns,
      selectable: true
    )
  end

  # @label Empty State
  # Table with no items showing empty state
  def empty_state
    columns = [
      { key: :name, label: "Product" },
      { key: :price, label: "Price" }
    ]

    empty_state = {
      title: "No products found",
      description: "Get started by creating a new product.",
      action: { label: "Add Product", path: "#new" }
    }

    render BetterPage::Ui::TableComponent.new(
      items: [],
      columns: columns,
      empty_state: empty_state
    )
  end

  # @label With Date Formatting
  # Table with various date formats
  def with_dates
    items = [
      { id: 1, name: "Order #1001", created_at: Time.now - 1.day, updated_at: Time.now },
      { id: 2, name: "Order #1002", created_at: Time.now - 2.days, updated_at: Time.now - 1.hour },
      { id: 3, name: "Order #1003", created_at: Time.now - 5.days, updated_at: Time.now - 2.days }
    ]

    columns = [
      { key: :name, label: "Order" },
      { key: :created_at, label: "Created", format: :date },
      { key: :updated_at, label: "Last Updated", format: :datetime }
    ]

    render BetterPage::Ui::TableComponent.new(items: items, columns: columns)
  end

  # @label Full Example
  # Complete table with all features
  def full_example
    items = [
      { id: 1, name: "Premium Plan", price: 99.00, users: 150, active: true, conversion: 85 },
      { id: 2, name: "Business Plan", price: 199.00, users: 75, active: true, conversion: 72 },
      { id: 3, name: "Enterprise", price: 499.00, users: 25, active: false, conversion: 45 }
    ]

    columns = [
      { key: :name, label: "Plan" },
      { key: :price, label: "Price", format: :currency },
      { key: :users, label: "Users" },
      { key: :active, label: "Status", format: :boolean },
      { key: :conversion, label: "Conversion", format: :percentage }
    ]

    row_actions = ->(item) {
      [
        { label: "View", path: "#view-#{item[:id]}" },
        { label: "Edit", path: "#edit-#{item[:id]}", style: :primary },
        { label: "Delete", path: "#delete-#{item[:id]}", style: :danger }
      ]
    }

    render BetterPage::Ui::TableComponent.new(
      items: items,
      columns: columns,
      row_actions: row_actions,
      selectable: true
    )
  end

  # @label With Row Links
  # Clickable rows that navigate to detail page
  def with_row_links
    items = [
      { id: 1, name: "iPhone 15", price: 999.00, category: "Phones" },
      { id: 2, name: "MacBook Pro", price: 2499.00, category: "Laptops" },
      { id: 3, name: "AirPods Pro", price: 249.00, category: "Audio" }
    ]

    columns = [
      { key: :name, label: "Product" },
      { key: :price, label: "Price", format: :currency },
      { key: :category, label: "Category" }
    ]

    row_link = ->(item) { "#product-#{item[:id]}" }

    render BetterPage::Ui::TableComponent.new(
      items: items,
      columns: columns,
      row_link: row_link
    )
  end

  # @label With Dropdown Actions
  # Actions displayed in a dropdown menu (3 dots)
  def with_dropdown_actions
    items = [
      { id: 1, name: "John Doe", email: "john@example.com", role: "Admin" },
      { id: 2, name: "Jane Smith", email: "jane@example.com", role: "User" },
      { id: 3, name: "Bob Wilson", email: "bob@example.com", role: "Editor" }
    ]

    columns = [
      { key: :name, label: "Name" },
      { key: :email, label: "Email" },
      { key: :role, label: "Role" }
    ]

    row_actions = ->(item) {
      [
        { label: "View Profile", path: "#view-#{item[:id]}" },
        { label: "Edit", path: "#edit-#{item[:id]}", style: :primary },
        { label: "Send Email", path: "#email-#{item[:id]}" },
        { label: "Delete", path: "#delete-#{item[:id]}", style: :danger, confirm: "Are you sure?" }
      ]
    }

    render BetterPage::Ui::TableComponent.new(
      items: items,
      columns: columns,
      row_actions: row_actions,
      actions_display: :dropdown
    )
  end

  # @label Combined Features
  # Row links + dropdown actions + selectable
  def combined_features
    items = [
      { id: 1, name: "Premium Plan", price: 99.00, subscribers: 1500, active: true },
      { id: 2, name: "Business Plan", price: 199.00, subscribers: 750, active: true },
      { id: 3, name: "Enterprise", price: 499.00, subscribers: 120, active: false }
    ]

    columns = [
      { key: :name, label: "Plan" },
      { key: :price, label: "Price", format: :currency },
      { key: :subscribers, label: "Subscribers" },
      { key: :active, label: "Status", format: :boolean }
    ]

    row_link = ->(item) { "#plan-#{item[:id]}" }

    row_actions = ->(item) {
      [
        { label: "Edit", path: "#edit-#{item[:id]}", style: :primary },
        { label: "Duplicate", path: "#duplicate-#{item[:id]}" },
        { label: "Archive", path: "#archive-#{item[:id]}", style: :danger }
      ]
    }

    render BetterPage::Ui::TableComponent.new(
      items: items,
      columns: columns,
      row_link: row_link,
      row_actions: row_actions,
      actions_display: :dropdown,
      selectable: true
    )
  end
end
