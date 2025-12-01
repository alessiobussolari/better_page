# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::Ui::HeaderComponent, type: :component do
  describe "rendering" do
    it "renders with just a title" do
      render_inline(described_class.new(title: "Products"))

      expect(page).to have_css("h1", text: "Products")
    end

    it "renders breadcrumbs when provided" do
      breadcrumbs = [
        { label: "Home", path: "/" },
        { label: "Products" }
      ]

      render_inline(described_class.new(title: "Products", breadcrumbs: breadcrumbs))

      expect(page).to have_css("nav[aria-label='Breadcrumb']")
      expect(page).to have_link("Home", href: "/")
      expect(page).to have_text("Products")
    end

    it "renders actions when provided" do
      actions = [
        { label: "New", path: "/new", style: :primary },
        { label: "Export", path: "/export", style: :secondary }
      ]

      render_inline(described_class.new(title: "Products", actions: actions))

      expect(page).to have_link("New", href: "/new")
      expect(page).to have_link("Export", href: "/export")
    end

    it "renders metadata when provided" do
      metadata = [
        { value: "128 items" },
        { value: "Updated today" }
      ]

      render_inline(described_class.new(title: "Products", metadata: metadata))

      expect(page).to have_text("128 items")
      expect(page).to have_text("Updated today")
    end

    it "applies primary action style" do
      actions = [{ label: "Save", path: "#", style: :primary }]

      render_inline(described_class.new(title: "Test", actions: actions))

      expect(page).to have_css("a.bg-blue-600", text: "Save")
    end

    it "applies danger action style" do
      actions = [{ label: "Delete", path: "#", style: :danger }]

      render_inline(described_class.new(title: "Test", actions: actions))

      expect(page).to have_css("a.bg-red-600", text: "Delete")
    end

    it "applies secondary action style" do
      actions = [{ label: "Cancel", path: "#", style: :secondary }]

      render_inline(described_class.new(title: "Test", actions: actions))

      expect(page).to have_css("a.bg-white", text: "Cancel")
    end
  end

  describe "predicate methods" do
    it "returns true for breadcrumbs? when breadcrumbs present" do
      component = described_class.new(title: "Test", breadcrumbs: [{ label: "Home" }])
      expect(component.breadcrumbs?).to be true
    end

    it "returns false for breadcrumbs? when empty" do
      component = described_class.new(title: "Test")
      expect(component.breadcrumbs?).to be false
    end

    it "returns true for actions? when actions present" do
      component = described_class.new(title: "Test", actions: [{ label: "Save", path: "#" }])
      expect(component.actions?).to be true
    end

    it "returns false for actions? when empty" do
      component = described_class.new(title: "Test")
      expect(component.actions?).to be false
    end

    it "returns true for metadata? when metadata present" do
      component = described_class.new(title: "Test", metadata: [{ value: "Info" }])
      expect(component.metadata?).to be true
    end

    it "returns false for metadata? when empty" do
      component = described_class.new(title: "Test")
      expect(component.metadata?).to be false
    end
  end

  describe "#action_classes" do
    let(:component) { described_class.new(title: "Test") }

    it "returns primary classes" do
      classes = component.action_classes(:primary)
      expect(classes).to include("bg-blue-600")
    end

    it "returns secondary classes" do
      classes = component.action_classes(:secondary)
      expect(classes).to include("bg-white")
    end

    it "returns danger classes" do
      classes = component.action_classes(:danger)
      expect(classes).to include("bg-red-600")
    end

    it "returns default classes for unknown style" do
      classes = component.action_classes(:unknown)
      expect(classes).to include("bg-white")
    end

    it "returns default classes for nil style" do
      classes = component.action_classes(nil)
      expect(classes).to include("bg-white")
    end
  end
end
