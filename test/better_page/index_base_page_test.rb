# frozen_string_literal: true

require "test_helper"

class BetterPage::IndexBasePageTest < ActiveSupport::TestCase
  class TestIndexPage < BetterPage::IndexBasePage
    def initialize(items = [], user: nil)
      @test_items = items
      @test_user = user
      super(items, { user: user })
    end

    def header
      {
        title: "Test Index",
        breadcrumbs: [{ label: "Home", path: "/" }],
        metadata: [{ label: "Count", value: @test_items.size }],
        actions: [{ label: "New", path: "/new", icon: "plus" }]
      }
    end

    def table
      {
        items: @test_items,
        columns: [
          { key: :name, label: "Name", type: :text },
          { key: :email, label: "Email", type: :text }
        ],
        empty_state: {
          icon: "inbox",
          title: "No items",
          message: "Create your first item"
        }
      }
    end
  end

  class MinimalIndexPage < BetterPage::IndexBasePage
    def header
      { title: "Minimal" }
    end

    def table
      { items: [] }
    end
  end

  test "inherits from BasePage" do
    assert BetterPage::IndexBasePage < BetterPage::BasePage
  end

  test "registers required header component" do
    definition = BetterPage::IndexBasePage.registered_components[:header]

    assert definition.required?
    assert_not_nil definition.schema
  end

  test "registers required table component" do
    definition = BetterPage::IndexBasePage.registered_components[:table]

    assert definition.required?
    assert_not_nil definition.schema
  end

  test "registers optional components with defaults" do
    components = BetterPage::IndexBasePage.registered_components

    assert_equal [], components[:alerts].default
    assert_equal [], components[:statistics].default
    assert_equal [], components[:metrics].default
    assert_equal({ enabled: false }, components[:pagination].default)
    assert_equal({ enabled: false }, components[:overview].default)
    assert_equal({ enabled: false }, components[:footer].default)
    assert_equal [], components[:modals].default
  end

  test "index method builds complete page" do
    items = [{ name: "Test", email: "test@example.com" }]
    page = TestIndexPage.new(items)
    result = page.index

    assert result.key?(:header)
    assert result.key?(:table)
    assert result.key?(:alerts)
    assert result.key?(:statistics)
    assert result.key?(:pagination)
  end

  test "index includes header data" do
    page = TestIndexPage.new([])
    result = page.index

    assert_equal "Test Index", result[:header][:title]
    assert_equal 1, result[:header][:breadcrumbs].size
    assert_equal 1, result[:header][:actions].size
  end

  test "index includes table data" do
    items = [{ name: "Alice" }, { name: "Bob" }]
    page = TestIndexPage.new(items)
    result = page.index

    assert_equal items, result[:table][:items]
    assert_equal 2, result[:table][:columns].size
    assert_equal "inbox", result[:table][:empty_state][:icon]
  end

  test "index uses default values for optional components" do
    page = MinimalIndexPage.new
    result = page.index

    assert_equal [], result[:alerts]
    assert_equal [], result[:statistics]
    assert_equal false, result[:pagination][:enabled]
  end

  test "tabs component has correct default structure" do
    page = MinimalIndexPage.new
    result = page.index

    assert_equal false, result[:tabs][:enabled]
    assert_equal "all", result[:tabs][:current_tab]
    assert_equal [], result[:tabs][:tabs]
  end

  test "search component has correct default structure" do
    page = MinimalIndexPage.new
    result = page.index

    assert_equal false, result[:search][:enabled]
    assert_equal "Search...", result[:search][:placeholder]
    assert_equal "", result[:search][:current_search]
    assert_equal 0, result[:search][:results_count]
  end

  test "split_view component has correct default structure" do
    page = MinimalIndexPage.new
    result = page.index

    assert_equal false, result[:split_view][:enabled]
    assert_nil result[:split_view][:selected_id]
    assert_equal [], result[:split_view][:items]
    assert_equal "Items", result[:split_view][:list_title]
    assert_equal "Details", result[:split_view][:detail_title]
  end

  test "split_view_empty_state_format helper builds empty state" do
    page = TestIndexPage.new
    result = page.send(:split_view_empty_state_format,
                       icon: "click",
                       title: "Select item",
                       message: "Click to view")

    assert_equal "click", result[:icon]
    assert_equal "Select item", result[:title]
    assert_equal "Click to view", result[:message]
  end
end
