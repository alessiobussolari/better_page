# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::Config do
  let(:components) do
    {
      header: { title: "Users", breadcrumbs: [] },
      table: { items: [], columns: [] },
      statistics: [{ label: "Total", value: 100 }],
      alerts: []
    }
  end

  let(:meta) do
    {
      page_type: :index,
      klass: Class.new
    }
  end

  describe "#initialize" do
    context "with components and meta" do
      subject(:config) { described_class.new(components, meta: meta) }

      it "sets the components" do
        expect(config.components).to eq(components)
      end

      it "sets the meta" do
        expect(config.meta[:page_type]).to eq(:index)
      end
    end

    context "with default meta" do
      subject(:config) { described_class.new(components) }

      it "defaults page_type to nil" do
        expect(config.meta[:page_type]).to be_nil
      end

      it "defaults klass to nil" do
        expect(config.meta[:klass]).to be_nil
      end
    end

    context "with non-hash meta" do
      subject(:config) { described_class.new(components, meta: "invalid") }

      it "defaults to hash with nil values" do
        expect(config.meta).to eq({ page_type: nil, klass: nil })
      end
    end
  end

  describe "component accessors" do
    subject(:config) { described_class.new(components, meta: meta) }

    it "returns header component" do
      expect(config.header).to eq({ title: "Users", breadcrumbs: [] })
    end

    it "returns table component" do
      expect(config.table).to eq({ items: [], columns: [] })
    end

    it "returns statistics component" do
      expect(config.statistics).to eq([{ label: "Total", value: 100 }])
    end

    it "returns alerts component" do
      expect(config.alerts).to eq([])
    end

    it "returns nil for missing component" do
      expect(config.tabs).to be_nil
    end

    context "all component accessors" do
      let(:full_components) do
        {
          header: { title: "Test" },
          table: { items: [] },
          statistics: [],
          alerts: [],
          tabs: { items: [] },
          pagination: { current_page: 1 },
          overview: { enabled: true },
          footer: { text: "Footer" },
          panel: { title: "Panel" },
          errors: ["Error 1"],
          content_section: { title: "Section" },
          widget: { type: :chart }
        }
      end
      subject(:config) { described_class.new(full_components) }

      it "returns pagination component" do
        expect(config.pagination).to eq({ current_page: 1 })
      end

      it "returns overview component" do
        expect(config.overview).to eq({ enabled: true })
      end

      it "returns footer component" do
        expect(config.footer).to eq({ text: "Footer" })
      end

      it "returns panel component" do
        expect(config.panel).to eq({ title: "Panel" })
      end

      it "returns errors component" do
        expect(config.errors).to eq(["Error 1"])
      end

      it "returns content_section component" do
        expect(config.content_section).to eq({ title: "Section" })
      end

      it "returns widget component" do
        expect(config.widget).to eq({ type: :chart })
      end
    end
  end

  describe "meta accessors" do
    subject(:config) { described_class.new(components, meta: meta) }

    it "returns page_type" do
      expect(config.page_type).to eq(:index)
    end

    it "returns klass" do
      expect(config.klass).to be_a(Class)
    end
  end

  describe "#to_ary" do
    subject(:config) { described_class.new(components, meta: meta) }

    it "enables destructuring" do
      comps, m = config

      expect(comps).to eq(components)
      expect(m[:page_type]).to eq(:index)
    end
  end

  describe "#deconstruct" do
    subject(:config) { described_class.new(components) }

    it "is alias for to_ary" do
      expect(config.deconstruct).to eq(config.to_ary)
    end
  end

  describe "destructuring" do
    context "in method returns" do
      subject(:config) { described_class.new(components, meta: meta) }

      it "works correctly" do
        comps, m = config

        expect(comps[:header][:title]).to eq("Users")
        expect(m[:page_type]).to eq(:index)
      end
    end
  end

  describe "#[]" do
    subject(:config) { described_class.new(components, meta: meta) }

    it "accesses component by key" do
      expect(config[:header]).to eq({ title: "Users", breadcrumbs: [] })
    end

    it "accesses meta key when component not found" do
      expect(config[:page_type]).to eq(:index)
    end

    it "returns nil for unknown keys" do
      expect(config[:nonexistent]).to be_nil
    end
  end

  describe "#dig" do
    subject(:config) { described_class.new(components, meta: meta) }

    it "digs into component" do
      expect(config.dig(:header, :title)).to eq("Users")
    end

    it "digs into nested structures" do
      expect(config.dig(:statistics, 0, :label)).to eq("Total")
    end

    it "returns nil for empty keys" do
      expect(config.dig).to be_nil
    end

    it "returns nil for missing keys" do
      expect(config.dig(:nonexistent)).to be_nil
    end

    it "returns nil for deep missing keys" do
      expect(config.dig(:header, :nonexistent)).to be_nil
    end

    it "returns nil when intermediate is not diggable" do
      config_with_string = described_class.new({ header: "string" })
      expect(config_with_string.dig(:header, :something)).to be_nil
    end
  end

  describe "#key?" do
    subject(:config) { described_class.new(components, meta: meta) }

    it "returns true for existing component" do
      expect(config.key?(:header)).to be true
    end

    it "returns true for existing meta key" do
      expect(config.key?(:page_type)).to be true
    end

    it "returns false for unknown keys" do
      expect(config.key?(:unknown)).to be false
    end
  end

  describe "#has_key?" do
    subject(:config) { described_class.new(components, meta: meta) }

    it "is an alias for key?" do
      expect(config.has_key?(:header)).to be true
      expect(config.has_key?(:unknown)).to be false
    end
  end

  describe "#to_h" do
    subject(:config) { described_class.new(components, meta: meta) }

    it "returns hash with components" do
      expect(config.to_h[:components]).to eq(components)
    end

    it "returns hash with meta" do
      expect(config.to_h[:meta][:page_type]).to eq(:index)
    end
  end

  describe "#component_names" do
    subject(:config) { described_class.new(components) }

    it "returns array of component names" do
      expect(config.component_names).to contain_exactly(:header, :table, :statistics, :alerts)
    end
  end

  describe "#component?" do
    context "when component is present" do
      subject(:config) { described_class.new(components) }

      it "returns true for non-empty hash" do
        expect(config.component?(:header)).to be true
      end

      it "returns true for non-empty array" do
        expect(config.component?(:statistics)).to be true
      end
    end

    context "when component is empty" do
      subject(:config) { described_class.new(components) }

      it "returns false for empty array" do
        expect(config.component?(:alerts)).to be false
      end
    end

    context "when component is nil" do
      subject(:config) { described_class.new({}) }

      it "returns false" do
        expect(config.component?(:header)).to be false
      end
    end

    context "when component has enabled: false" do
      subject(:config) do
        described_class.new({ tabs: { enabled: false } })
      end

      it "returns false" do
        expect(config.component?(:tabs)).to be false
      end
    end
  end

  describe "#each_component" do
    subject(:config) { described_class.new(components) }

    it "iterates over all components" do
      names = []
      config.each_component { |name, _| names << name }
      expect(names).to contain_exactly(:header, :table, :statistics, :alerts)
    end
  end

  describe "#present_components" do
    subject(:config) { described_class.new(components) }

    it "returns only non-empty components" do
      present = config.present_components
      expect(present.keys).to contain_exactly(:header, :table, :statistics)
      expect(present.keys).not_to include(:alerts)
    end
  end

  describe "real-world usage patterns" do
    let(:index_components) do
      {
        header: { title: "Products", breadcrumbs: [{ label: "Home", path: "/" }] },
        table: { items: [1, 2, 3], columns: [:name, :price] },
        statistics: [{ label: "Total", value: 3 }],
        pagination: { current_page: 1, total_pages: 1 }
      }
    end

    let(:index_meta) do
      {
        page_type: :index,
        klass: Class.new
      }
    end

    subject(:config) { described_class.new(index_components, meta: index_meta) }

    it "allows accessing header title" do
      expect(config.header[:title]).to eq("Products")
    end

    it "allows accessing with []" do
      expect(config[:header][:title]).to eq("Products")
    end

    it "allows digging into nested structures" do
      expect(config.dig(:header, :breadcrumbs, 0, :label)).to eq("Home")
    end

    it "allows destructuring for controller use" do
      components, meta = config
      expect(components[:table][:items].size).to eq(3)
      expect(meta[:page_type]).to eq(:index)
    end

    it "can check for presence of optional components" do
      expect(config.component?(:pagination)).to be true
      expect(config.component?(:alerts)).to be false
    end

    it "can iterate over present components" do
      config.present_components.each do |name, value|
        expect(value).not_to be_nil
        expect(value).not_to be_empty if value.respond_to?(:empty?)
      end
    end
  end
end
