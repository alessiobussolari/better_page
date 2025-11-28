# frozen_string_literal: true

require "test_helper"

class BetterPage::CustomBasePageTest < ActiveSupport::TestCase
  class TestCustomPage < BetterPage::CustomBasePage
    def initialize(data = {}, user: nil)
      @data = data
      super(data, { user: user })
    end

    def header
      {
        title: "Dashboard",
        breadcrumbs: [{ label: "Home", path: "/" }],
        metadata: [{ label: "Last Updated", value: "Today" }],
        actions: [{ label: "Refresh", path: "/refresh", icon: "refresh" }]
      }
    end

    def content
      {
        widgets: build_widgets,
        charts: build_charts
      }
    end

    private

    def build_widgets
      [
        widget_format(
          title: "Total Users",
          type: :counter,
          data: { value: @data[:users_count] || 0 }
        )
      ]
    end

    def build_charts
      [
        chart_format(
          title: "Revenue",
          type: :line,
          data: { labels: [], datasets: [] }
        )
      ]
    end
  end

  class MinimalCustomPage < BetterPage::CustomBasePage
    def content
      { data: "minimal" }
    end
  end

  test "inherits from BasePage" do
    assert BetterPage::CustomBasePage < BetterPage::BasePage
  end

  test "registers required content component" do
    definition = BetterPage::CustomBasePage.registered_components[:content]

    assert definition.required?
  end

  test "registers optional header component" do
    definition = BetterPage::CustomBasePage.registered_components[:header]

    refute definition.required?
    assert_nil definition.default
  end

  test "registers optional footer component" do
    definition = BetterPage::CustomBasePage.registered_components[:footer]

    refute definition.required?
    assert_nil definition.default
  end

  test "custom method builds complete page" do
    page = TestCustomPage.new({ users_count: 100 })
    result = page.custom

    assert result.key?(:header)
    assert result.key?(:content)
    assert result.key?(:footer)
  end

  test "custom includes header data" do
    page = TestCustomPage.new
    result = page.custom

    assert_equal "Dashboard", result[:header][:title]
    assert_equal 1, result[:header][:breadcrumbs].size
    assert_equal 1, result[:header][:actions].size
  end

  test "custom includes content data" do
    page = TestCustomPage.new({ users_count: 100 })
    result = page.custom

    assert result[:content].key?(:widgets)
    assert result[:content].key?(:charts)
    assert_equal 1, result[:content][:widgets].size
    assert_equal 1, result[:content][:charts].size
  end

  test "custom returns nil for undefined optional header" do
    page = MinimalCustomPage.new
    result = page.custom

    assert_nil result[:header]
    assert_nil result[:footer]
  end

  test "widget_format builds widget hash" do
    page = TestCustomPage.new
    result = page.send(:widget_format,
                       title: "Orders",
                       type: :counter,
                       data: { value: 50, change: 5 },
                       color: "blue")

    assert_equal "Orders", result[:title]
    assert_equal :counter, result[:type]
    assert_equal({ value: 50, change: 5 }, result[:data])
    assert_equal "blue", result[:color]
  end

  test "chart_format builds chart hash" do
    page = TestCustomPage.new
    data = {
      labels: %w[Jan Feb Mar],
      datasets: [{ label: "Sales", data: [10, 20, 30] }]
    }
    result = page.send(:chart_format,
                       title: "Monthly Sales",
                       type: :bar,
                       data: data,
                       height: 300)

    assert_equal "Monthly Sales", result[:title]
    assert_equal :bar, result[:type]
    assert_equal data, result[:data]
    assert_equal 300, result[:height]
  end

  test "widget_format supports additional options" do
    page = TestCustomPage.new
    result = page.send(:widget_format,
                       title: "Test",
                       type: :gauge,
                       data: { value: 75 },
                       min: 0,
                       max: 100,
                       threshold: 80)

    assert_equal 0, result[:min]
    assert_equal 100, result[:max]
    assert_equal 80, result[:threshold]
  end

  test "chart_format supports additional options" do
    page = TestCustomPage.new
    result = page.send(:chart_format,
                       title: "Test Chart",
                       type: :pie,
                       data: { labels: [], values: [] },
                       legend: true,
                       colors: %w[red blue green])

    assert_equal true, result[:legend]
    assert_equal %w[red blue green], result[:colors]
  end
end
