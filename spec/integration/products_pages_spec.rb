# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Products Pages Integration", type: :integration do
  # Create a mock Product struct for testing
  let(:product_class) do
    Struct.new(:id, :name, :price, :stock, :active, :description, :category, keyword_init: true) do
      def formatted_price
        "$#{format('%.2f', price)}"
      end

      def status
        active ? "Active" : "Inactive"
      end

      def active?
        active
      end
    end
  end

  let(:products) do
    [
      product_class.new(id: 1, name: "Widget", price: 29.99, stock: 100, active: true, description: "A great widget", category: "Widgets"),
      product_class.new(id: 2, name: "Gadget", price: 49.99, stock: 50, active: true, description: "An amazing gadget", category: "Gadgets"),
      product_class.new(id: 3, name: "Thingamajig", price: 19.99, stock: 0, active: false, description: "A thing", category: "Things")
    ]
  end

  let(:product) { products.first }
  let(:user) { double("User", name: "Test User", admin?: true) }

  describe "Products::IndexPage" do
    let(:page) { Products::IndexPage.new(products, user: user) }

    describe "#index" do
      let(:result) { page.index }

      it "returns a BetterPage::Config" do
        expect(result).to be_a(BetterPage::Config)
      end

      it "includes header with title" do
        expect(result[:header][:title]).to eq("Products")
      end

      it "includes header breadcrumbs" do
        expect(result[:header][:breadcrumbs]).to be_an(Array)
        expect(result[:header][:breadcrumbs].first[:label]).to eq("Home")
      end

      it "includes header actions" do
        expect(result[:header][:actions]).to be_an(Array)
        expect(result[:header][:actions].first[:label]).to eq("New Product")
      end

      it "includes table with items" do
        expect(result[:table][:items]).to eq(products)
      end

      it "includes table columns" do
        columns = result[:table][:columns]
        expect(columns.map { |c| c[:key] }).to include(:id, :name, :formatted_price, :stock, :status)
      end

      it "includes table empty state" do
        expect(result[:table][:empty_state][:title]).to eq("No products found")
      end

      it "includes statistics" do
        stats = result[:statistics]
        expect(stats.map { |s| s[:label] }).to include("Total", "Active", "Inactive")
      end

      it "calculates correct statistics values" do
        stats = result[:statistics]
        total_stat = stats.find { |s| s[:label] == "Total" }
        active_stat = stats.find { |s| s[:label] == "Active" }
        inactive_stat = stats.find { |s| s[:label] == "Inactive" }

        expect(total_stat[:value]).to eq(3)
        expect(active_stat[:value]).to eq(2)
        expect(inactive_stat[:value]).to eq(1)
      end
    end

    describe "#frame_index" do
      it "returns table component for turbo frame" do
        result = page.frame_index(:table)

        expect(result[:component]).to eq(:table)
        expect(result[:config]).to have_key(:items)
      end
    end

    describe "#stream_index" do
      it "returns multiple components for turbo stream" do
        result = page.stream_index(:table, :statistics)

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result.map { |c| c[:component] }).to contain_exactly(:table, :statistics)
      end
    end
  end

  describe "Products::ShowPage" do
    let(:page) { Products::ShowPage.new(product, user: user) }

    describe "#show" do
      let(:result) { page.show }

      it "returns a BetterPage::Config" do
        expect(result).to be_a(BetterPage::Config)
      end

      it "includes header with product name as title" do
        expect(result[:header][:title]).to eq("Widget")
      end

      it "includes header actions" do
        expect(result[:header][:actions]).to be_an(Array)
      end
    end
  end

  describe "Products::NewPage" do
    let(:new_product) { product_class.new(id: nil, name: "", price: 0, stock: 0, active: true) }
    let(:page) { Products::NewPage.new(new_product, user: user) }

    describe "#form" do
      let(:result) { page.form }

      it "returns a BetterPage::Config" do
        expect(result).to be_a(BetterPage::Config)
      end

      it "includes header with New Product title" do
        expect(result[:header][:title]).to eq("New Product")
      end

      it "includes panels" do
        expect(result[:panels]).to be_an(Array)
        expect(result[:panels]).not_to be_empty
      end
    end
  end

  describe "Products::EditPage" do
    let(:page) { Products::EditPage.new(product, user: user) }

    describe "#form" do
      let(:result) { page.form }

      it "returns a BetterPage::Config" do
        expect(result).to be_a(BetterPage::Config)
      end

      it "includes header with Edit prefix" do
        expect(result[:header][:title]).to include("Edit")
      end

      it "includes panels with fields" do
        expect(result[:panels]).to be_an(Array)
      end
    end
  end

  describe "Page inheritance" do
    it "IndexPage inherits from IndexBasePage" do
      expect(Products::IndexPage.superclass).to eq(IndexBasePage)
    end

    it "ShowPage inherits from ShowBasePage" do
      expect(Products::ShowPage.superclass).to eq(ShowBasePage)
    end

    it "NewPage inherits from FormBasePage" do
      expect(Products::NewPage.superclass).to eq(FormBasePage)
    end

    it "EditPage inherits from FormBasePage" do
      expect(Products::EditPage.superclass).to eq(FormBasePage)
    end
  end

  describe "URL helpers availability" do
    let(:page) { Products::IndexPage.new(products, user: user) }

    it "can access Rails route helpers" do
      result = page.index

      # Check that paths are properly generated (not nil)
      action = result[:header][:actions].first
      expect(action[:path]).not_to be_nil
    end
  end
end
