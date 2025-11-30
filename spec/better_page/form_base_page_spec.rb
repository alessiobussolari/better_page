# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::FormBasePage do
  let(:test_form_page_class) do
    Class.new(BetterPage::FormBasePage) do
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
  end

  let(:minimal_form_page_class) do
    Class.new(BetterPage::FormBasePage) do
      def header
        { title: "Minimal Form" }
      end

      def panels
        [{ title: "Main", fields: [] }]
      end
    end
  end

  let(:violating_form_page_class) do
    Class.new(BetterPage::FormBasePage) do
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
  end

  describe "inheritance" do
    it "inherits from BasePage" do
      expect(BetterPage::FormBasePage < BetterPage::BasePage).to be true
    end
  end

  describe "component registration" do
    it "registers required header component" do
      definition = BetterPage::FormBasePage.effective_components[:header]

      expect(definition.required?).to be true
      expect(definition.schema).not_to be_nil
    end

    it "registers required panels component" do
      definition = BetterPage::FormBasePage.effective_components[:panels]

      expect(definition.required?).to be true
    end

    it "registers optional components with defaults" do
      components = BetterPage::FormBasePage.effective_components

      expect(components[:alerts].default).to eq([])
      expect(components[:errors].default).to be_nil
      expect(components[:footer].default[:primary_action]).to eq({ label: "Save", style: :primary })
    end
  end

  describe "#form" do
    it "builds complete page" do
      page = test_form_page_class.new
      result = page.form

      expect(result).to have_key(:header)
      expect(result).to have_key(:panels)
      expect(result).to have_key(:alerts)
      expect(result).to have_key(:errors)
      expect(result).to have_key(:footer)
    end

    it "includes header data" do
      page = test_form_page_class.new
      result = page.form

      expect(result[:header][:title]).to eq("New Item")
      expect(result[:header][:description]).to eq("Fill in the form below")
      expect(result[:header][:breadcrumbs].size).to eq(2)
    end

    it "includes panels with fields" do
      page = test_form_page_class.new
      result = page.form

      expect(result[:panels].size).to eq(2)
      expect(result[:panels][0][:title]).to eq("Basic Information")
      expect(result[:panels][0][:fields].size).to eq(2)
    end

    it "uses default footer structure" do
      page = minimal_form_page_class.new
      result = page.form

      expect(result[:footer][:primary_action][:label]).to eq("Save")
      expect(result[:footer][:primary_action][:style]).to eq(:primary)
      expect(result[:footer][:secondary_actions]).to eq([])
    end
  end

  describe "#field_format" do
    it "builds field hash" do
      page = test_form_page_class.new
      result = page.send(:field_format,
                         name: :username,
                         type: :text,
                         label: "Username",
                         required: true,
                         placeholder: "Enter username")

      expect(result[:name]).to eq(:username)
      expect(result[:type]).to eq(:text)
      expect(result[:label]).to eq("Username")
      expect(result[:required]).to be true
      expect(result[:placeholder]).to eq("Enter username")
    end
  end

  describe "#panel_format" do
    let(:page) { test_form_page_class.new }

    it "builds panel hash" do
      fields = [{ name: :test, type: :text, label: "Test" }]
      result = page.send(:panel_format,
                         title: "Test Panel",
                         fields: fields,
                         description: "A test panel",
                         icon: "form")

      expect(result[:title]).to eq("Test Panel")
      expect(result[:fields]).to eq(fields)
      expect(result[:description]).to eq("A test panel")
      expect(result[:icon]).to eq("form")
    end

    it "omits optional keys when nil" do
      result = page.send(:panel_format,
                         title: "Simple",
                         fields: [])

      expect(result).to have_key(:title)
      expect(result).to have_key(:fields)
      expect(result).not_to have_key(:description)
      expect(result).not_to have_key(:icon)
    end
  end

  describe "#default_breadcrumbs" do
    it "returns empty array" do
      page = test_form_page_class.new
      result = page.send(:default_breadcrumbs)

      expect(result).to eq([])
    end
  end

  describe "#resource_name" do
    it "extracts from class name" do
      # Use a named class for this test
      stub_const("Products::NewPage", Class.new(BetterPage::FormBasePage) do
        def header
          { title: "Test" }
        end

        def panels
          []
        end
      end)

      page = Products::NewPage.new
      result = page.send(:resource_name)

      expect(result).to eq("new")
    end
  end

  describe "panel validation" do
    it "validates panel rules in development" do
      page = violating_form_page_class.new

      # Should not raise, just log warnings in development
      result = page.form
      expect(result).to have_key(:panels)
    end
  end
end
