# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::Configuration do
  let(:config) { described_class.new }

  describe "#initialize" do
    it "initializes with empty components" do
      expect(config.components).to eq({})
    end

    it "initializes page_type_components with empty arrays" do
      expect(config.page_type_components).to eq(
        index: [],
        show: [],
        form: [],
        custom: []
      )
    end

    it "initializes required_components with empty arrays" do
      expect(config.required_components).to eq(
        index: [],
        show: [],
        form: [],
        custom: []
      )
    end
  end

  describe "#register_component" do
    it "registers a component without schema" do
      config.register_component :sidebar, default: { enabled: false }

      expect(config.components[:sidebar]).to be_a(BetterPage::ComponentDefinition)
      expect(config.components[:sidebar].default).to eq(enabled: false)
    end

    it "registers a component with required flag" do
      config.register_component :header, required: true

      expect(config.components[:header].required?).to be true
    end

    it "registers a component with schema block" do
      config.register_component :header do
        required(:title).filled(:string)
      end

      component = config.components[:header]
      expect(component.schema).not_to be_nil
    end

    it "registers multiple components" do
      config.register_component :header
      config.register_component :footer

      expect(config.component_names).to contain_exactly(:header, :footer)
    end
  end

  describe "#allow_components" do
    it "maps components to a page type" do
      config.allow_components :index, :header, :table

      expect(config.components_for(:index)).to contain_exactly(:header, :table)
    end

    it "appends components on multiple calls" do
      config.allow_components :index, :header
      config.allow_components :index, :table, :pagination

      expect(config.components_for(:index)).to contain_exactly(:header, :table, :pagination)
    end

    it "removes duplicates" do
      config.allow_components :index, :header, :table
      config.allow_components :index, :header, :pagination

      expect(config.components_for(:index)).to contain_exactly(:header, :table, :pagination)
    end

    it "supports array syntax" do
      config.allow_components :show, %i[header statistics]

      expect(config.components_for(:show)).to contain_exactly(:header, :statistics)
    end
  end

  describe "#require_components" do
    it "marks components as required for a page type" do
      config.require_components :index, :header, :table

      expect(config.required_components[:index]).to contain_exactly(:header, :table)
    end

    it "appends on multiple calls" do
      config.require_components :form, :header
      config.require_components :form, :panels

      expect(config.required_components[:form]).to contain_exactly(:header, :panels)
    end

    it "removes duplicates" do
      config.require_components :custom, :content
      config.require_components :custom, :content, :header

      expect(config.required_components[:custom]).to contain_exactly(:content, :header)
    end
  end

  describe "#components_for" do
    it "returns components for a page type" do
      config.allow_components :index, :header, :table

      expect(config.components_for(:index)).to eq([ :header, :table ])
    end

    it "returns empty array for unknown page type" do
      expect(config.components_for(:unknown)).to eq([])
    end
  end

  describe "#component_required?" do
    before do
      config.register_component :header, required: true
      config.register_component :footer, required: false
      config.require_components :index, :table
    end

    it "returns true for page type required components" do
      expect(config.component_required?(:index, :table)).to be true
    end

    it "returns true for globally required components" do
      expect(config.component_required?(:show, :header)).to be true
    end

    it "returns false for non-required components" do
      expect(config.component_required?(:show, :footer)).to be false
    end

    it "returns false for unknown components" do
      expect(config.component_required?(:index, :unknown)).to be false
    end
  end

  describe "#component" do
    it "returns component definition by name" do
      config.register_component :header, default: { title: "" }

      expect(config.component(:header)).to be_a(BetterPage::ComponentDefinition)
    end

    it "returns nil for unknown component" do
      expect(config.component(:unknown)).to be_nil
    end
  end

  describe "#component_names" do
    it "returns all registered component names" do
      config.register_component :header
      config.register_component :table
      config.register_component :footer

      expect(config.component_names).to contain_exactly(:header, :table, :footer)
    end

    it "returns empty array when no components registered" do
      expect(config.component_names).to eq([])
    end
  end

  describe "#reset!" do
    before do
      config.register_component :header
      config.allow_components :index, :header
      config.require_components :index, :header
    end

    it "clears all components" do
      config.reset!

      expect(config.components).to eq({})
    end

    it "resets page type components" do
      config.reset!

      expect(config.page_type_components).to eq(
        index: [],
        show: [],
        form: [],
        custom: []
      )
    end

    it "resets required components" do
      config.reset!

      expect(config.required_components).to eq(
        index: [],
        show: [],
        form: [],
        custom: []
      )
    end
  end

  describe "#dup" do
    before do
      config.register_component :header
      config.allow_components :index, :header, :table
      config.require_components :index, :header
    end

    it "creates a copy of the configuration" do
      copy = config.dup

      expect(copy).not_to be(config)
      expect(copy.component_names).to eq(config.component_names)
    end

    it "deep copies page_type_components" do
      copy = config.dup
      copy.allow_components :index, :pagination

      expect(config.components_for(:index)).not_to include(:pagination)
      expect(copy.components_for(:index)).to include(:pagination)
    end

    it "deep copies required_components" do
      copy = config.dup
      copy.require_components :index, :table

      expect(config.required_components[:index]).not_to include(:table)
      expect(copy.required_components[:index]).to include(:table)
    end
  end
end
