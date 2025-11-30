# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::IndexBasePage do
  let(:test_index_page_class) do
    Class.new(BetterPage::IndexBasePage) do
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
  end

  let(:minimal_index_page_class) do
    Class.new(BetterPage::IndexBasePage) do
      def header
        { title: "Minimal" }
      end

      def table
        { items: [] }
      end
    end
  end

  describe "inheritance" do
    it "inherits from BasePage" do
      expect(BetterPage::IndexBasePage < BetterPage::BasePage).to be true
    end
  end

  describe "component registration" do
    it "registers required header component" do
      definition = BetterPage::IndexBasePage.registered_components[:header]

      expect(definition.required?).to be true
      expect(definition.schema).not_to be_nil
    end

    it "registers required table component" do
      definition = BetterPage::IndexBasePage.registered_components[:table]

      expect(definition.required?).to be true
      expect(definition.schema).not_to be_nil
    end

    it "registers optional components with defaults" do
      components = BetterPage::IndexBasePage.registered_components

      expect(components[:alerts].default).to eq([])
      expect(components[:statistics].default).to eq([])
      expect(components[:metrics].default).to eq([])
      expect(components[:pagination].default).to eq({ enabled: false })
      expect(components[:overview].default).to eq({ enabled: false })
      expect(components[:footer].default).to eq({ enabled: false })
      expect(components[:modals].default).to eq([])
    end
  end

  describe "#index" do
    it "builds complete page" do
      items = [{ name: "Test", email: "test@example.com" }]
      page = test_index_page_class.new(items)
      result = page.index

      expect(result).to have_key(:header)
      expect(result).to have_key(:table)
      expect(result).to have_key(:alerts)
      expect(result).to have_key(:statistics)
      expect(result).to have_key(:pagination)
    end

    it "includes header data" do
      page = test_index_page_class.new([])
      result = page.index

      expect(result[:header][:title]).to eq("Test Index")
      expect(result[:header][:breadcrumbs].size).to eq(1)
      expect(result[:header][:actions].size).to eq(1)
    end

    it "includes table data" do
      items = [{ name: "Alice" }, { name: "Bob" }]
      page = test_index_page_class.new(items)
      result = page.index

      expect(result[:table][:items]).to eq(items)
      expect(result[:table][:columns].size).to eq(2)
      expect(result[:table][:empty_state][:icon]).to eq("inbox")
    end

    it "uses default values for optional components" do
      page = minimal_index_page_class.new
      result = page.index

      expect(result[:alerts]).to eq([])
      expect(result[:statistics]).to eq([])
      expect(result[:pagination][:enabled]).to be false
    end

    it "includes klass for self-rendering" do
      page = minimal_index_page_class.new
      result = page.index

      expect(result).to have_key(:klass)
    end
  end

  describe "tabs component" do
    it "has correct default structure" do
      page = minimal_index_page_class.new
      result = page.index

      expect(result[:tabs][:enabled]).to be false
      expect(result[:tabs][:current_tab]).to eq("all")
      expect(result[:tabs][:tabs]).to eq([])
    end
  end

  describe "search component" do
    it "has correct default structure" do
      page = minimal_index_page_class.new
      result = page.index

      expect(result[:search][:enabled]).to be false
      expect(result[:search][:placeholder]).to eq("Search...")
      expect(result[:search][:current_search]).to eq("")
      expect(result[:search][:results_count]).to eq(0)
    end
  end

  describe "split_view component" do
    it "has correct default structure" do
      page = minimal_index_page_class.new
      result = page.index

      expect(result[:split_view][:enabled]).to be false
      expect(result[:split_view][:selected_id]).to be_nil
      expect(result[:split_view][:items]).to eq([])
      expect(result[:split_view][:list_title]).to eq("Items")
      expect(result[:split_view][:detail_title]).to eq("Details")
    end
  end

  describe "#split_view_empty_state_format" do
    it "builds empty state" do
      page = test_index_page_class.new
      result = page.send(:split_view_empty_state_format,
                         icon: "click",
                         title: "Select item",
                         message: "Click to view")

      expect(result[:icon]).to eq("click")
      expect(result[:title]).to eq("Select item")
      expect(result[:message]).to eq("Click to view")
    end
  end

  describe "#view_component_class" do
    it "raises NotImplementedError when ViewComponent not defined" do
      page = minimal_index_page_class.new

      if defined?(BetterPage::IndexViewComponent)
        original = BetterPage::IndexViewComponent
        BetterPage.send(:remove_const, :IndexViewComponent)
        begin
          expect { page.view_component_class }.to raise_error(NotImplementedError)
        ensure
          BetterPage.const_set(:IndexViewComponent, original)
        end
      else
        expect { page.view_component_class }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#stream_index" do
    it "returns array of component configurations" do
      page = minimal_index_page_class.new
      result = page.stream_index

      expect(result).to be_an(Array)
    end

    it "filters by component name" do
      page = test_index_page_class.new([{ name: "Test" }])
      result = page.stream_index(:table)

      component_names = result.map { |c| c[:component] }
      expect(component_names).to include(:table)
      expect(component_names).not_to include(:alerts)
    end

    it "includes target for turbo streams" do
      page = test_index_page_class.new([{ name: "Test" }])
      result = page.stream_index(:table)

      table_component = result.find { |c| c[:component] == :table }
      expect(table_component).not_to be_nil
      expect(table_component[:target]).to eq("better_page_table")
    end
  end

  describe "#stream_components" do
    it "returns default components for stream updates" do
      page = minimal_index_page_class.new

      expect(page.stream_components).to eq(%i[alerts statistics table pagination])
    end
  end

  describe "#frame_index" do
    it "returns single component configuration" do
      page = test_index_page_class.new([{ name: "Test" }])
      result = page.frame_index(:table)

      expect(result).to be_a(Hash)
      expect(result[:component]).to eq(:table)
      expect(result[:target]).to eq("better_page_table")
    end

    it "returns nil for empty component" do
      page = minimal_index_page_class.new
      result = page.frame_index(:alerts)

      expect(result).to be_nil
    end
  end
end
