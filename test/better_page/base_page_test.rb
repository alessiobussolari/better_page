# frozen_string_literal: true

require "test_helper"

class BetterPage::BasePageTest < ActiveSupport::TestCase
  class TestBasePage < BetterPage::BasePage
    register_component :test_component, default: {}

    def test_component
      { value: "test" }
    end
  end

  test "includes url helpers" do
    page = TestBasePage.new([])
    # Check that the module is included, not a specific path method
    assert TestBasePage.include?(Rails.application.routes.url_helpers)
  end

  test "includes component registry" do
    assert TestBasePage.registered_components.key?(:test_component)
  end

  test "initializes with new pattern (primary_data, metadata)" do
    data = [1, 2, 3]
    metadata = { user: "test_user", stats: { count: 10 } }

    page = TestBasePage.new(data, metadata)

    assert_equal data, page.primary_data
    assert_equal metadata, page.metadata
    assert_equal "test_user", page.user
    assert_equal({ count: 10 }, page.stats)
  end

  test "initializes with primary data only" do
    data = [1, 2, 3]
    page = TestBasePage.new(data)

    assert_equal data, page.primary_data
    assert_equal({}, page.metadata)
  end

  test "count_text returns singular form for count of 1" do
    page = TestBasePage.new([])
    result = page.send(:count_text, 1, "item", "items")

    assert_equal "1 item", result
  end

  test "count_text returns plural form for count not 1" do
    page = TestBasePage.new([])

    assert_equal "0 items", page.send(:count_text, 0, "item", "items")
    assert_equal "2 items", page.send(:count_text, 2, "item", "items")
    assert_equal "100 items", page.send(:count_text, 100, "item", "items")
  end

  test "format_date formats date with default format" do
    page = TestBasePage.new([])
    date = Date.new(2025, 1, 28)
    result = page.send(:format_date, date)

    assert_equal "28/01/2025", result
  end

  test "format_date accepts custom format" do
    page = TestBasePage.new([])
    date = Date.new(2025, 1, 28)
    result = page.send(:format_date, date, "%Y-%m-%d")

    assert_equal "2025-01-28", result
  end

  test "format_date returns N/A for nil" do
    page = TestBasePage.new([])
    result = page.send(:format_date, nil)

    assert_equal "N/A", result
  end

  test "percentage calculates correctly" do
    page = TestBasePage.new([])

    assert_equal 50.0, page.send(:percentage, 1, 2)
    assert_equal 33.3, page.send(:percentage, 1, 3)
    assert_equal 100.0, page.send(:percentage, 5, 5)
  end

  test "percentage returns 0 when total is zero" do
    page = TestBasePage.new([])
    result = page.send(:percentage, 5, 0)

    assert_equal 0, result
  end

  test "empty_state_with_action builds basic empty state" do
    page = TestBasePage.new([])
    result = page.send(:empty_state_with_action,
                       icon: "inbox",
                       title: "No items",
                       message: "Create your first item")

    assert_equal "inbox", result[:icon]
    assert_equal "No items", result[:title]
    assert_equal "Create your first item", result[:message]
    refute result.key?(:action)
  end

  test "empty_state_with_action includes action when provided" do
    page = TestBasePage.new([])
    result = page.send(:empty_state_with_action,
                       icon: "inbox",
                       title: "No items",
                       message: "Create your first item",
                       action_label: "Add Item",
                       action_path: "/items/new",
                       action_icon: "add")

    assert result.key?(:action)
    assert_equal "Add Item", result[:action][:label]
    assert_equal "/items/new", result[:action][:path]
    assert_equal "add", result[:action][:icon]
  end

  test "default configuration methods return expected defaults" do
    page = TestBasePage.new([])

    assert_equal [], page.send(:breadcrumbs_config)
    assert_equal [], page.send(:default_metadata)
    assert_equal [], page.send(:default_actions)
    assert_equal [], page.send(:default_alerts)
    assert_equal [], page.send(:default_statistics)
  end

  test "default_tabs_config returns disabled tabs" do
    page = TestBasePage.new([])
    result = page.send(:default_tabs_config)

    assert_equal false, result[:enabled]
    assert_equal "all", result[:current_tab]
    assert_equal [], result[:tabs]
  end

  test "default_table_config returns empty table structure" do
    page = TestBasePage.new([1, 2, 3])
    result = page.send(:default_table_config)

    assert_equal [1, 2, 3], result[:items]
    assert result[:empty_state].key?(:icon)
    assert_equal [], result[:columns]
  end

  test "default_footer_info returns disabled footer" do
    page = TestBasePage.new([])
    result = page.send(:default_footer_info)

    assert_equal false, result[:enabled]
    assert_equal "Information", result[:title]
    assert_equal [], result[:sections]
  end
end
