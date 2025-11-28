# frozen_string_literal: true

require "test_helper"

class BetterPage::ShowBasePageTest < ActiveSupport::TestCase
  class TestShowPage < BetterPage::ShowBasePage
    def initialize(item, user: nil)
      @test_item = item
      super(item, { user: user })
    end

    def header
      {
        title: @test_item[:name],
        breadcrumbs: [
          { label: "Home", path: "/" },
          { label: "Items", path: "/items" }
        ],
        metadata: [{ label: "ID", value: @test_item[:id] }],
        actions: [
          { path: "/edit", label: "Edit", icon: "edit", style: "primary" }
        ]
      }
    end

    def content_sections
      [
        {
          title: "Details",
          icon: "info",
          color: "blue",
          type: :info_grid,
          items: [
            { name: "Name", value: @test_item[:name] },
            { name: "Email", value: @test_item[:email] }
          ]
        }
      ]
    end
  end

  class MinimalShowPage < BetterPage::ShowBasePage
    def header
      { title: "Minimal Show" }
    end
  end

  test "inherits from BasePage" do
    assert BetterPage::ShowBasePage < BetterPage::BasePage
  end

  test "registers required header component" do
    definition = BetterPage::ShowBasePage.registered_components[:header]

    assert definition.required?
    assert_not_nil definition.schema
  end

  test "registers optional components with defaults" do
    components = BetterPage::ShowBasePage.registered_components

    assert_equal [], components[:alerts].default
    assert_equal [], components[:statistics].default
    assert_equal({ enabled: false }, components[:overview].default)
    assert_equal [], components[:content_sections].default
    assert_equal({ enabled: false }, components[:footer].default)
  end

  test "show method builds complete page" do
    item = { id: 1, name: "Test Item", email: "test@example.com" }
    page = TestShowPage.new(item)
    result = page.show

    assert result.key?(:header)
    assert result.key?(:alerts)
    assert result.key?(:statistics)
    assert result.key?(:content_sections)
    assert result.key?(:footer)
  end

  test "show includes header data" do
    item = { id: 1, name: "Test Item", email: "test@example.com" }
    page = TestShowPage.new(item)
    result = page.show

    assert_equal "Test Item", result[:header][:title]
    assert_equal 2, result[:header][:breadcrumbs].size
    assert_equal 1, result[:header][:actions].size
  end

  test "show includes content sections" do
    item = { id: 1, name: "Test Item", email: "test@example.com" }
    page = TestShowPage.new(item)
    result = page.show

    assert_equal 1, result[:content_sections].size
    assert_equal "Details", result[:content_sections].first[:title]
  end

  test "show uses default values for optional components" do
    page = MinimalShowPage.new
    result = page.show

    assert_equal [], result[:alerts]
    assert_equal [], result[:statistics]
    assert_equal false, result[:overview][:enabled]
  end

  test "info_grid_content_format converts hash to array" do
    page = TestShowPage.new({ id: 1, name: "Test", email: "test@example.com" })
    result = page.send(:info_grid_content_format, { "Name" => "Test", "Email" => "test@example.com" })

    assert_equal 2, result.size
    assert result.all? { |item| item.key?(:name) && item.key?(:value) }
  end

  test "content_section_format builds info_grid section" do
    page = TestShowPage.new({ id: 1, name: "Test", email: "test@example.com" })
    result = page.send(:content_section_format,
                       title: "Info",
                       icon: "info",
                       color: "blue",
                       type: :info_grid,
                       content: { "Name" => "Test" })

    assert_equal "Info", result[:title]
    assert_equal "info", result[:icon]
    assert_equal "blue", result[:color]
    assert_equal :info_grid, result[:type]
    assert result.key?(:items)
  end

  test "content_section_format builds text_content section" do
    page = TestShowPage.new({ id: 1, name: "Test", email: "test@example.com" })
    result = page.send(:content_section_format,
                       title: "Description",
                       icon: "text",
                       color: "gray",
                       type: :text_content,
                       content: "Some text content")

    assert_equal :text_content, result[:type]
    assert_equal "Some text content", result[:content]
  end

  test "statistic_format builds statistic hash" do
    page = TestShowPage.new({ id: 1, name: "Test", email: "test@example.com" })
    result = page.send(:statistic_format,
                       label: "Total",
                       value: 100,
                       icon: "chart",
                       color: "green")

    assert_equal "Total", result[:label]
    assert_equal 100, result[:value]
    assert_equal "chart", result[:icon]
    assert_equal "green", result[:color]
  end

  test "action_format builds action hash" do
    page = TestShowPage.new({ id: 1, name: "Test", email: "test@example.com" })
    result = page.send(:action_format,
                       path: "/edit",
                       label: "Edit",
                       icon: "edit",
                       style: "primary",
                       method: :patch)

    assert_equal "/edit", result[:path]
    assert_equal "Edit", result[:label]
    assert_equal "edit", result[:icon]
    assert_equal "primary", result[:style]
    assert_equal :patch, result[:method]
  end

  test "action_format defaults method to get" do
    page = TestShowPage.new({ id: 1, name: "Test", email: "test@example.com" })
    result = page.send(:action_format,
                       path: "/show",
                       label: "View",
                       icon: "eye",
                       style: "secondary")

    assert_equal :get, result[:method]
  end
end
