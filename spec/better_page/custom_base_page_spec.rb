# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::CustomBasePage do
  let(:test_custom_page_class) do
    Class.new(BetterPage::CustomBasePage) do
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
  end

  let(:minimal_custom_page_class) do
    Class.new(BetterPage::CustomBasePage) do
      def content
        { data: "minimal" }
      end
    end
  end

  describe "inheritance" do
    it "inherits from BasePage" do
      expect(BetterPage::CustomBasePage < BetterPage::BasePage).to be true
    end
  end

  describe "component registration" do
    it "registers required content component" do
      definition = BetterPage::CustomBasePage.registered_components[:content]

      expect(definition.required?).to be true
    end

    it "registers optional header component" do
      definition = BetterPage::CustomBasePage.registered_components[:header]

      expect(definition.required?).to be false
      expect(definition.default).to be_nil
    end

    it "registers optional footer component" do
      definition = BetterPage::CustomBasePage.registered_components[:footer]

      expect(definition.required?).to be false
      expect(definition.default).to be_nil
    end
  end

  describe "#custom" do
    it "builds complete page" do
      page = test_custom_page_class.new({ users_count: 100 })
      result = page.custom

      expect(result).to have_key(:header)
      expect(result).to have_key(:content)
      expect(result).to have_key(:footer)
    end

    it "includes header data" do
      page = test_custom_page_class.new
      result = page.custom

      expect(result[:header][:title]).to eq("Dashboard")
      expect(result[:header][:breadcrumbs].size).to eq(1)
      expect(result[:header][:actions].size).to eq(1)
    end

    it "includes content data" do
      page = test_custom_page_class.new({ users_count: 100 })
      result = page.custom

      expect(result[:content]).to have_key(:widgets)
      expect(result[:content]).to have_key(:charts)
      expect(result[:content][:widgets].size).to eq(1)
      expect(result[:content][:charts].size).to eq(1)
    end

    it "returns nil for undefined optional header" do
      page = minimal_custom_page_class.new
      result = page.custom

      expect(result[:header]).to be_nil
      expect(result[:footer]).to be_nil
    end
  end

  describe "#widget_format" do
    let(:page) { test_custom_page_class.new }

    it "builds widget hash" do
      result = page.send(:widget_format,
                         title: "Orders",
                         type: :counter,
                         data: { value: 50, change: 5 },
                         color: "blue")

      expect(result[:title]).to eq("Orders")
      expect(result[:type]).to eq(:counter)
      expect(result[:data]).to eq({ value: 50, change: 5 })
      expect(result[:color]).to eq("blue")
    end

    it "supports additional options" do
      result = page.send(:widget_format,
                         title: "Test",
                         type: :gauge,
                         data: { value: 75 },
                         min: 0,
                         max: 100,
                         threshold: 80)

      expect(result[:min]).to eq(0)
      expect(result[:max]).to eq(100)
      expect(result[:threshold]).to eq(80)
    end
  end

  describe "#chart_format" do
    let(:page) { test_custom_page_class.new }

    it "builds chart hash" do
      data = {
        labels: %w[Jan Feb Mar],
        datasets: [{ label: "Sales", data: [10, 20, 30] }]
      }
      result = page.send(:chart_format,
                         title: "Monthly Sales",
                         type: :bar,
                         data: data,
                         height: 300)

      expect(result[:title]).to eq("Monthly Sales")
      expect(result[:type]).to eq(:bar)
      expect(result[:data]).to eq(data)
      expect(result[:height]).to eq(300)
    end

    it "supports additional options" do
      result = page.send(:chart_format,
                         title: "Test Chart",
                         type: :pie,
                         data: { labels: [], values: [] },
                         legend: true,
                         colors: %w[red blue green])

      expect(result[:legend]).to be true
      expect(result[:colors]).to eq(%w[red blue green])
    end
  end
end
