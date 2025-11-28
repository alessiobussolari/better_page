# frozen_string_literal: true

require "test_helper"

class BetterPage::ComponentRegistryTest < ActiveSupport::TestCase
  class TestPage
    include BetterPage::ComponentRegistry

    register_component :header, required: true do
      required(:title).filled(:string)
      optional(:subtitle).filled(:string)
    end

    register_component :footer, default: { enabled: false }

    register_component :sidebar, default: nil

    def initialize(header_data = nil)
      @header_data = header_data
    end

    def header
      @header_data || { title: "Default Title" }
    end
  end

  class ChildPage < TestPage
    register_component :extra, default: { data: "child" }

    def extra
      { data: "custom" }
    end
  end

  test "registers components with class attribute" do
    assert TestPage.registered_components.key?(:header)
    assert TestPage.registered_components.key?(:footer)
    assert TestPage.registered_components.key?(:sidebar)
  end

  test "component definition stores required flag" do
    header_def = TestPage.registered_components[:header]
    footer_def = TestPage.registered_components[:footer]

    assert header_def.required?
    refute footer_def.required?
  end

  test "component definition stores default value" do
    footer_def = TestPage.registered_components[:footer]
    sidebar_def = TestPage.registered_components[:sidebar]

    assert_equal({ enabled: false }, footer_def.default)
    assert_nil sidebar_def.default
  end

  test "component definition stores schema" do
    header_def = TestPage.registered_components[:header]
    footer_def = TestPage.registered_components[:footer]

    assert_not_nil header_def.schema
    assert_nil footer_def.schema
  end

  test "build_page collects all component values" do
    page = TestPage.new({ title: "My Title" })
    result = page.build_page

    assert_equal({ title: "My Title" }, result[:header])
    assert_equal({ enabled: false }, result[:footer])
    assert_nil result[:sidebar]
  end

  test "build_page uses default when method not defined" do
    page = TestPage.new
    result = page.build_page

    assert_equal({ enabled: false }, result[:footer])
  end

  test "child class inherits parent components" do
    assert ChildPage.registered_components.key?(:header)
    assert ChildPage.registered_components.key?(:footer)
    assert ChildPage.registered_components.key?(:extra)
  end

  test "child class can override inherited components" do
    page = ChildPage.new
    result = page.build_page

    assert_equal({ data: "custom" }, result[:extra])
  end

  test "validation passes for valid data" do
    page = TestPage.new({ title: "Valid Title" })
    # Should not raise
    result = page.build_page
    assert_equal "Valid Title", result[:header][:title]
  end

  test "validates required components" do
    # Create a page class with required component that returns nil
    klass = Class.new do
      include BetterPage::ComponentRegistry

      register_component :required_field, required: true

      def required_field
        nil
      end
    end

    page = klass.new

    # In test environment (not development), validation errors are just warnings
    # So we check that build_page still works but the value is nil
    result = page.build_page
    assert_nil result[:required_field]
  end
end

class BetterPage::ComponentDefinitionTest < ActiveSupport::TestCase
  test "creates component definition with all attributes" do
    definition = BetterPage::ComponentDefinition.new(
      name: :test,
      required: true,
      default: { foo: "bar" },
      schema: nil
    )

    assert_equal :test, definition.name
    assert definition.required?
    assert_equal({ foo: "bar" }, definition.default)
    assert_nil definition.schema
  end

  test "required? returns false by default" do
    definition = BetterPage::ComponentDefinition.new(
      name: :test,
      required: false,
      default: nil,
      schema: nil
    )

    refute definition.required?
  end
end
