# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::ShowBasePage do
  let(:test_show_page_class) do
    Class.new(BetterPage::ShowBasePage) do
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
  end

  let(:minimal_show_page_class) do
    Class.new(BetterPage::ShowBasePage) do
      def header
        { title: "Minimal Show" }
      end
    end
  end

  describe "inheritance" do
    it "inherits from BasePage" do
      expect(BetterPage::ShowBasePage < BetterPage::BasePage).to be true
    end
  end

  describe "component registration" do
    it "registers required header component" do
      definition = BetterPage::ShowBasePage.registered_components[:header]

      expect(definition.required?).to be true
      expect(definition.schema).not_to be_nil
    end

    it "registers optional components with defaults" do
      components = BetterPage::ShowBasePage.registered_components

      expect(components[:alerts].default).to eq([])
      expect(components[:statistics].default).to eq([])
      expect(components[:overview].default).to eq({ enabled: false })
      expect(components[:content_sections].default).to eq([])
      expect(components[:footer].default).to eq({ enabled: false })
    end
  end

  describe "#show" do
    it "builds complete page" do
      item = { id: 1, name: "Test Item", email: "test@example.com" }
      page = test_show_page_class.new(item)
      result = page.show

      expect(result).to have_key(:header)
      expect(result).to have_key(:alerts)
      expect(result).to have_key(:statistics)
      expect(result).to have_key(:content_sections)
      expect(result).to have_key(:footer)
    end

    it "includes header data" do
      item = { id: 1, name: "Test Item", email: "test@example.com" }
      page = test_show_page_class.new(item)
      result = page.show

      expect(result[:header][:title]).to eq("Test Item")
      expect(result[:header][:breadcrumbs].size).to eq(2)
      expect(result[:header][:actions].size).to eq(1)
    end

    it "includes content sections" do
      item = { id: 1, name: "Test Item", email: "test@example.com" }
      page = test_show_page_class.new(item)
      result = page.show

      expect(result[:content_sections].size).to eq(1)
      expect(result[:content_sections].first[:title]).to eq("Details")
    end

    it "uses default values for optional components" do
      page = minimal_show_page_class.new
      result = page.show

      expect(result[:alerts]).to eq([])
      expect(result[:statistics]).to eq([])
      expect(result[:overview][:enabled]).to be false
    end
  end

  describe "#info_grid_content_format" do
    it "converts hash to array" do
      page = test_show_page_class.new({ id: 1, name: "Test", email: "test@example.com" })
      result = page.send(:info_grid_content_format, { "Name" => "Test", "Email" => "test@example.com" })

      expect(result.size).to eq(2)
      expect(result.all? { |item| item.key?(:name) && item.key?(:value) }).to be true
    end
  end

  describe "#content_section_format" do
    let(:page) { test_show_page_class.new({ id: 1, name: "Test", email: "test@example.com" }) }

    it "builds info_grid section" do
      result = page.send(:content_section_format,
                         title: "Info",
                         icon: "info",
                         color: "blue",
                         type: :info_grid,
                         content: { "Name" => "Test" })

      expect(result[:title]).to eq("Info")
      expect(result[:icon]).to eq("info")
      expect(result[:color]).to eq("blue")
      expect(result[:type]).to eq(:info_grid)
      expect(result).to have_key(:items)
    end

    it "builds text_content section" do
      result = page.send(:content_section_format,
                         title: "Description",
                         icon: "text",
                         color: "gray",
                         type: :text_content,
                         content: "Some text content")

      expect(result[:type]).to eq(:text_content)
      expect(result[:content]).to eq("Some text content")
    end
  end

  describe "#statistic_format" do
    it "builds statistic hash" do
      page = test_show_page_class.new({ id: 1, name: "Test", email: "test@example.com" })
      result = page.send(:statistic_format,
                         label: "Total",
                         value: 100,
                         icon: "chart",
                         color: "green")

      expect(result[:label]).to eq("Total")
      expect(result[:value]).to eq(100)
      expect(result[:icon]).to eq("chart")
      expect(result[:color]).to eq("green")
    end
  end

  describe "#action_format" do
    let(:page) { test_show_page_class.new({ id: 1, name: "Test", email: "test@example.com" }) }

    it "builds action hash" do
      result = page.send(:action_format,
                         path: "/edit",
                         label: "Edit",
                         icon: "edit",
                         style: "primary",
                         method: :patch)

      expect(result[:path]).to eq("/edit")
      expect(result[:label]).to eq("Edit")
      expect(result[:icon]).to eq("edit")
      expect(result[:style]).to eq("primary")
      expect(result[:method]).to eq(:patch)
    end

    it "defaults method to get" do
      result = page.send(:action_format,
                         path: "/show",
                         label: "View",
                         icon: "eye",
                         style: "secondary")

      expect(result[:method]).to eq(:get)
    end
  end
end
