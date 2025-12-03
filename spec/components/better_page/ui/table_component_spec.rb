# frozen_string_literal: true

require "rails_helper"
require "ostruct"

RSpec.describe BetterPage::Ui::TableComponent, type: :component do
  let(:items) do
    [
      { id: 1, name: "Product A", price: 100, active: true },
      { id: 2, name: "Product B", price: 200, active: false }
    ]
  end

  let(:columns) do
    [
      { key: :name, label: "Name" },
      { key: :price, label: "Price" }
    ]
  end

  describe "rendering" do
    it "renders a table with items" do
      render_inline(described_class.new(items: items, columns: columns))

      expect(page).to have_css("table")
      expect(page).to have_css("th", text: "Name")
      expect(page).to have_css("th", text: "Price")
      expect(page).to have_css("td", text: "Product A")
      expect(page).to have_css("td", text: "Product B")
    end

    it "renders empty state when no items" do
      empty_state = { title: "No items", description: "Create one" }

      render_inline(described_class.new(
        items: [],
        columns: columns,
        empty_state: empty_state
      ))

      expect(page).not_to have_css("table")
      expect(page).to have_text("No items")
      expect(page).to have_text("Create one")
    end

    it "renders empty state with action button" do
      empty_state = {
        title: "No items",
        action: { label: "Add Item", path: "/new" }
      }

      render_inline(described_class.new(
        items: [],
        columns: columns,
        empty_state: empty_state
      ))

      expect(page).to have_link("Add Item", href: "/new")
    end

    it "renders checkboxes when selectable" do
      render_inline(described_class.new(
        items: items,
        columns: columns,
        selectable: true
      ))

      expect(page).to have_css("input[type='checkbox']", count: 3) # header + 2 rows
    end

    it "renders row actions when provided" do
      row_actions = [
        { label: "Edit", path: "/edit", style: :primary },
        { label: "Delete", path: "/delete", style: :danger }
      ]

      render_inline(described_class.new(
        items: items,
        columns: columns,
        row_actions: row_actions
      ))

      expect(page).to have_link("Edit")
      expect(page).to have_link("Delete")
    end

    it "renders row actions from callable" do
      row_actions = ->(item) {
        [ { label: "View #{item[:name]}", path: "#" } ]
      }

      render_inline(described_class.new(
        items: items,
        columns: columns,
        row_actions: row_actions
      ))

      expect(page).to have_link("View Product A")
      expect(page).to have_link("View Product B")
    end
  end

  describe "#format_value" do
    let(:component) { described_class.new(items: [], columns: []) }

    it "formats currency" do
      item = { price: 99.99 }
      column = { key: :price, format: :currency }

      result = component.format_value(item, column)
      expect(result).to include("99.99")
    end

    it "formats date" do
      date = Date.new(2024, 1, 15)
      item = { created_at: date }
      column = { key: :created_at, format: :date }

      result = component.format_value(item, column)
      expect(result).to eq("January 15, 2024")
    end

    it "formats boolean as Yes/No" do
      item = { active: true }
      column = { key: :active, format: :boolean }

      expect(component.format_value(item, column)).to eq("Yes")

      item[:active] = false
      expect(component.format_value(item, column)).to eq("No")
    end

    it "formats percentage" do
      item = { rate: 85 }
      column = { key: :rate, format: :percentage }

      result = component.format_value(item, column)
      expect(result).to eq("85%")
    end

    it "returns raw value without format" do
      item = { name: "Test" }
      column = { key: :name }

      result = component.format_value(item, column)
      expect(result).to eq("Test")
    end
  end

  describe "predicate methods" do
    it "returns true for items? when items present" do
      component = described_class.new(items: items, columns: columns)
      expect(component.items?).to be true
    end

    it "returns false for items? when empty" do
      component = described_class.new(items: [], columns: columns)
      expect(component.items?).to be false
    end

    it "returns true for row_actions? when present" do
      component = described_class.new(
        items: items,
        columns: columns,
        row_actions: [ { label: "Edit", path: "#" } ]
      )
      expect(component.row_actions?).to be true
    end

    it "returns false for row_actions? when nil" do
      component = described_class.new(items: items, columns: columns)
      expect(component.row_actions?).to be false
    end

    it "returns true for empty_state? when present" do
      component = described_class.new(
        items: [],
        columns: columns,
        empty_state: { title: "Empty" }
      )
      expect(component.empty_state?).to be true
    end

    it "returns false for empty_state? when nil" do
      component = described_class.new(items: [], columns: columns)
      expect(component.empty_state?).to be false
    end

    it "returns true for selectable? when enabled" do
      component = described_class.new(items: items, columns: columns, selectable: true)
      expect(component.selectable?).to be true
    end

    it "returns false for selectable? when disabled" do
      component = described_class.new(items: items, columns: columns)
      expect(component.selectable?).to be false
    end
  end

  describe "#action_link_class" do
    let(:component) { described_class.new(items: [], columns: []) }

    it "returns danger classes" do
      classes = component.action_link_class(:danger)
      expect(classes).to include("text-red-600")
    end

    it "returns primary classes" do
      classes = component.action_link_class(:primary)
      expect(classes).to include("text-indigo-600")
    end

    it "returns default classes for unknown style" do
      classes = component.action_link_class(:unknown)
      expect(classes).to include("text-gray-600")
    end

    it "returns default classes for nil style" do
      classes = component.action_link_class(nil)
      expect(classes).to include("text-gray-600")
    end
  end

  describe "row_link feature" do
    it "returns true for row_link? when present" do
      component = described_class.new(
        items: items,
        columns: columns,
        row_link: ->(item) { "/items/#{item[:id]}" }
      )
      expect(component.row_link?).to be true
    end

    it "returns false for row_link? when nil" do
      component = described_class.new(items: items, columns: columns)
      expect(component.row_link?).to be false
    end

    it "evaluates link_for with callable" do
      component = described_class.new(
        items: items,
        columns: columns,
        row_link: ->(item) { "/items/#{item[:id]}" }
      )
      expect(component.link_for(items.first)).to eq("/items/1")
    end

    it "renders clickable rows with Turbo.visit" do
      render_inline(described_class.new(
        items: items,
        columns: columns,
        row_link: ->(item) { "/items/#{item[:id]}" }
      ))

      expect(page).to have_css("tr.cursor-pointer")
      expect(page).to have_css("tr[onclick*='Turbo.visit']")
    end
  end

  describe "actions_display feature" do
    it "defaults to inline" do
      component = described_class.new(items: items, columns: columns)
      expect(component.actions_display).to eq(:inline)
      expect(component.inline_actions?).to be true
      expect(component.dropdown_actions?).to be false
    end

    it "can be set to dropdown" do
      component = described_class.new(
        items: items,
        columns: columns,
        actions_display: :dropdown
      )
      expect(component.actions_display).to eq(:dropdown)
      expect(component.inline_actions?).to be false
      expect(component.dropdown_actions?).to be true
    end

    it "renders dropdown menu when actions_display is :dropdown" do
      row_actions = [
        { label: "Edit", path: "/edit" },
        { label: "Delete", path: "/delete" }
      ]

      render_inline(described_class.new(
        items: items,
        columns: columns,
        row_actions: row_actions,
        actions_display: :dropdown
      ))

      expect(page).to have_css("[data-controller='dropdown']")
      expect(page).to have_css("button[data-action='click->dropdown#toggle']")
      expect(page).to have_css("[data-dropdown-target='menu']")
    end

    it "renders inline links when actions_display is :inline" do
      row_actions = [
        { label: "Edit", path: "/edit" },
        { label: "Delete", path: "/delete" }
      ]

      render_inline(described_class.new(
        items: items,
        columns: columns,
        row_actions: row_actions,
        actions_display: :inline
      ))

      expect(page).not_to have_css("[data-controller='dropdown']")
      expect(page).to have_link("Edit")
      expect(page).to have_link("Delete")
    end
  end

  describe "#action_dropdown_class" do
    let(:component) { described_class.new(items: [], columns: []) }

    it "returns danger classes" do
      classes = component.action_dropdown_class(:danger)
      expect(classes).to include("text-red-600")
    end

    it "returns primary classes" do
      classes = component.action_dropdown_class(:primary)
      expect(classes).to include("text-indigo-600")
    end

    it "returns default classes for nil style" do
      classes = component.action_dropdown_class(nil)
      expect(classes).to include("text-gray-700")
    end
  end

  describe "#item_id" do
    let(:component) { described_class.new(items: [], columns: []) }

    it "returns id from hash" do
      item = { id: 42, name: "Test" }
      expect(component.item_id(item)).to eq(42)
    end

    it "returns id from object responding to id" do
      item = OpenStruct.new(id: 99, name: "Test")
      expect(component.item_id(item)).to eq(99)
    end
  end
end
