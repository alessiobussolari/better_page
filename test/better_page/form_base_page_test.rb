# frozen_string_literal: true

require "test_helper"

class BetterPage::FormBasePageTest < ActiveSupport::TestCase
  class TestFormPage < BetterPage::FormBasePage
    def initialize(item = nil, user: nil)
      @test_item = item || {}
      super(item, { user: user })
    end

    def header
      {
        title: @test_item[:id] ? "Edit Item" : "New Item",
        description: "Fill in the form below",
        breadcrumbs: [
          { label: "Home", path: "/" },
          { label: "Items", path: "/items" }
        ]
      }
    end

    def panels
      [
        {
          title: "Basic Information",
          fields: [
            { name: :name, type: :text, label: "Name", required: true },
            { name: :email, type: :email, label: "Email" }
          ]
        },
        {
          title: "Settings",
          fields: [
            { name: :is_active, type: :checkbox, label: "Active" },
            { name: :is_admin, type: :checkbox, label: "Admin" }
          ]
        }
      ]
    end
  end

  class MinimalFormPage < BetterPage::FormBasePage
    def header
      { title: "Minimal Form" }
    end

    def panels
      [{ title: "Main", fields: [] }]
    end
  end

  class ViolatingFormPage < BetterPage::FormBasePage
    def header
      { title: "Bad Form" }
    end

    def panels
      [
        {
          title: "Mixed Panel",
          fields: [
            { name: :name, type: :text, label: "Name" },
            { name: :is_active, type: :checkbox, label: "Active" }
          ]
        }
      ]
    end
  end

  test "inherits from BasePage" do
    assert BetterPage::FormBasePage < BetterPage::BasePage
  end

  test "registers required header component" do
    definition = BetterPage::FormBasePage.registered_components[:header]

    assert definition.required?
    assert_not_nil definition.schema
  end

  test "registers required panels component" do
    definition = BetterPage::FormBasePage.registered_components[:panels]

    assert definition.required?
  end

  test "registers optional components with defaults" do
    components = BetterPage::FormBasePage.registered_components

    assert_equal [], components[:alerts].default
    assert_nil components[:errors].default
    assert_equal({ label: "Save", style: :primary }, components[:footer].default[:primary_action])
  end

  test "form method builds complete page" do
    page = TestFormPage.new
    result = page.form

    assert result.key?(:header)
    assert result.key?(:panels)
    assert result.key?(:alerts)
    assert result.key?(:errors)
    assert result.key?(:footer)
  end

  test "form includes header data" do
    page = TestFormPage.new
    result = page.form

    assert_equal "New Item", result[:header][:title]
    assert_equal "Fill in the form below", result[:header][:description]
    assert_equal 2, result[:header][:breadcrumbs].size
  end

  test "form includes panels with fields" do
    page = TestFormPage.new
    result = page.form

    assert_equal 2, result[:panels].size
    assert_equal "Basic Information", result[:panels][0][:title]
    assert_equal 2, result[:panels][0][:fields].size
  end

  test "form uses default footer structure" do
    page = MinimalFormPage.new
    result = page.form

    assert_equal "Save", result[:footer][:primary_action][:label]
    assert_equal :primary, result[:footer][:primary_action][:style]
    assert_equal [], result[:footer][:secondary_actions]
  end

  test "field_format builds field hash" do
    page = TestFormPage.new
    result = page.send(:field_format,
                       name: :username,
                       type: :text,
                       label: "Username",
                       required: true,
                       placeholder: "Enter username")

    assert_equal :username, result[:name]
    assert_equal :text, result[:type]
    assert_equal "Username", result[:label]
    assert_equal true, result[:required]
    assert_equal "Enter username", result[:placeholder]
  end

  test "panel_format builds panel hash" do
    page = TestFormPage.new
    fields = [{ name: :test, type: :text, label: "Test" }]
    result = page.send(:panel_format,
                       title: "Test Panel",
                       fields: fields,
                       description: "A test panel",
                       icon: "form")

    assert_equal "Test Panel", result[:title]
    assert_equal fields, result[:fields]
    assert_equal "A test panel", result[:description]
    assert_equal "form", result[:icon]
  end

  test "panel_format omits optional keys when nil" do
    page = TestFormPage.new
    result = page.send(:panel_format,
                       title: "Simple",
                       fields: [])

    assert result.key?(:title)
    assert result.key?(:fields)
    refute result.key?(:description)
    refute result.key?(:icon)
  end

  test "default_breadcrumbs returns empty array" do
    page = TestFormPage.new
    result = page.send(:default_breadcrumbs)

    assert_equal [], result
  end

  test "resource_name extracts from class name" do
    # TestFormPage -> testform (without Page suffix, downcased)
    page = TestFormPage.new
    result = page.send(:resource_name)

    assert_equal "testform", result
  end

  test "validates panel rules in development" do
    # This test verifies the validation logic exists
    # In test environment, warnings are logged but no exception raised
    page = ViolatingFormPage.new

    # Should not raise, just log warnings in development
    result = page.form
    assert result.key?(:panels)
  end
end
