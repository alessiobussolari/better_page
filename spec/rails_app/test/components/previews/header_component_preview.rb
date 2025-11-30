# frozen_string_literal: true

class HeaderComponentPreview < ViewComponent::Preview
  # @label Default
  # Header with just a title
  def default
    render BetterPage::Ui::HeaderComponent.new(
      title: "Products"
    )
  end

  # @label With Breadcrumbs
  # Header with navigation breadcrumbs
  def with_breadcrumbs
    render BetterPage::Ui::HeaderComponent.new(
      title: "Products",
      breadcrumbs: [
        { label: "Home", path: "/" },
        { label: "Admin", path: "/admin" },
        { label: "Products" }
      ]
    )
  end

  # @label With Actions
  # Header with action buttons
  def with_actions
    render BetterPage::Ui::HeaderComponent.new(
      title: "Products",
      actions: [
        { label: "Export", path: "#", style: :secondary },
        { label: "New Product", path: "#", style: :primary }
      ]
    )
  end

  # @label With Metadata
  # Header with metadata information
  def with_metadata
    render BetterPage::Ui::HeaderComponent.new(
      title: "Users",
      metadata: [
        { value: "248 users" },
        { value: "195 active" }
      ]
    )
  end

  # @label Full Example
  # Header with all features
  def full_example
    render BetterPage::Ui::HeaderComponent.new(
      title: "Products",
      breadcrumbs: [
        { label: "Home", path: "/" },
        { label: "Admin", path: "/admin" },
        { label: "Products" }
      ],
      metadata: [
        { value: "128 items" },
        { value: "Last updated: Today" }
      ],
      actions: [
        { label: "Export", path: "#", style: :secondary },
        { label: "Delete All", path: "#", style: :danger },
        { label: "New Product", path: "#", style: :primary }
      ]
    )
  end
end
