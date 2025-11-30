# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::BasePage do
  let(:test_base_page_class) do
    Class.new(BetterPage::BasePage) do
      register_component :test_component, default: {}

      def test_component
        { value: "test" }
      end
    end
  end

  describe "URL helpers" do
    it "includes url helpers" do
      expect(test_base_page_class.include?(Rails.application.routes.url_helpers)).to be true
    end
  end

  describe "component registry" do
    it "includes component registry" do
      expect(test_base_page_class.registered_components).to have_key(:test_component)
    end
  end

  describe "initialization" do
    it "initializes with new pattern (primary_data, metadata)" do
      data = [1, 2, 3]
      metadata = { user: "test_user", stats: { count: 10 } }

      page = test_base_page_class.new(data, metadata)

      expect(page.primary_data).to eq(data)
      expect(page.metadata).to eq(metadata)
      expect(page.user).to eq("test_user")
      expect(page.stats).to eq({ count: 10 })
    end

    it "initializes with primary data only" do
      data = [1, 2, 3]
      page = test_base_page_class.new(data)

      expect(page.primary_data).to eq(data)
      expect(page.metadata).to eq({})
    end
  end

  describe "#count_text" do
    let(:page) { test_base_page_class.new([]) }

    it "returns singular form for count of 1" do
      result = page.send(:count_text, 1, "item", "items")
      expect(result).to eq("1 item")
    end

    it "returns plural form for count not 1" do
      expect(page.send(:count_text, 0, "item", "items")).to eq("0 items")
      expect(page.send(:count_text, 2, "item", "items")).to eq("2 items")
      expect(page.send(:count_text, 100, "item", "items")).to eq("100 items")
    end
  end

  describe "#format_date" do
    let(:page) { test_base_page_class.new([]) }

    it "formats date with default format" do
      date = Date.new(2025, 1, 28)
      result = page.send(:format_date, date)
      expect(result).to eq("28/01/2025")
    end

    it "accepts custom format" do
      date = Date.new(2025, 1, 28)
      result = page.send(:format_date, date, "%Y-%m-%d")
      expect(result).to eq("2025-01-28")
    end

    it "returns N/A for nil" do
      result = page.send(:format_date, nil)
      expect(result).to eq("N/A")
    end
  end

  describe "#percentage" do
    let(:page) { test_base_page_class.new([]) }

    it "calculates correctly" do
      expect(page.send(:percentage, 1, 2)).to eq(50.0)
      expect(page.send(:percentage, 1, 3)).to eq(33.3)
      expect(page.send(:percentage, 5, 5)).to eq(100.0)
    end

    it "returns 0 when total is zero" do
      result = page.send(:percentage, 5, 0)
      expect(result).to eq(0)
    end
  end

  describe "#empty_state_with_action" do
    let(:page) { test_base_page_class.new([]) }

    it "builds basic empty state" do
      result = page.send(:empty_state_with_action,
                         icon: "inbox",
                         title: "No items",
                         message: "Create your first item")

      expect(result[:icon]).to eq("inbox")
      expect(result[:title]).to eq("No items")
      expect(result[:message]).to eq("Create your first item")
      expect(result).not_to have_key(:action)
    end

    it "includes action when provided" do
      result = page.send(:empty_state_with_action,
                         icon: "inbox",
                         title: "No items",
                         message: "Create your first item",
                         action_label: "Add Item",
                         action_path: "/items/new",
                         action_icon: "add")

      expect(result).to have_key(:action)
      expect(result[:action][:label]).to eq("Add Item")
      expect(result[:action][:path]).to eq("/items/new")
      expect(result[:action][:icon]).to eq("add")
    end
  end

  describe "default configuration methods" do
    let(:page) { test_base_page_class.new([]) }

    it "returns expected defaults" do
      expect(page.send(:breadcrumbs_config)).to eq([])
      expect(page.send(:default_metadata)).to eq([])
      expect(page.send(:default_actions)).to eq([])
      expect(page.send(:default_alerts)).to eq([])
      expect(page.send(:default_statistics)).to eq([])
    end

    it "default_tabs_config returns disabled tabs" do
      result = page.send(:default_tabs_config)

      expect(result[:enabled]).to be false
      expect(result[:current_tab]).to eq("all")
      expect(result[:tabs]).to eq([])
    end

    it "default_table_config returns empty table structure" do
      page_with_data = test_base_page_class.new([1, 2, 3])
      result = page_with_data.send(:default_table_config)

      expect(result[:items]).to eq([1, 2, 3])
      expect(result[:empty_state]).to have_key(:icon)
      expect(result[:columns]).to eq([])
    end

    it "default_footer_info returns disabled footer" do
      result = page.send(:default_footer_info)

      expect(result[:enabled]).to be false
      expect(result[:title]).to eq("Information")
      expect(result[:sections]).to eq([])
    end
  end
end
