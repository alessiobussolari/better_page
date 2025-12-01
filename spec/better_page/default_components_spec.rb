# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::DefaultComponents do
  describe ".component_names" do
    it "returns all default component names" do
      names = described_class.component_names

      expect(names).to include(:header)
      expect(names).to include(:table)
      expect(names).to include(:alerts)
      expect(names).to include(:statistics)
      expect(names).to include(:pagination)
      expect(names).to include(:panels)
      expect(names).to include(:content)
    end

    it "returns expected number of components" do
      # header, table, alerts, statistics, metrics, tabs, search, pagination,
      # overview, calendar, footer, modals, split_view, content_sections,
      # errors, panels, content
      expect(described_class.component_names.size).to eq(17)
    end
  end

  describe ".register!" do
    let(:fresh_config) { BetterPage::Configuration.new }

    before do
      # Save original configuration
      @original_config = BetterPage.configuration

      # Use a fresh configuration for testing
      BetterPage.instance_variable_set(:@configuration, fresh_config)
    end

    after do
      # Restore original configuration
      BetterPage.instance_variable_set(:@configuration, @original_config)
    end

    it "registers all default components" do
      described_class.register!

      expect(BetterPage.configuration.component_names).to include(:header)
      expect(BetterPage.configuration.component_names).to include(:table)
      expect(BetterPage.configuration.component_names).to include(:footer)
    end

    it "maps components to index page type" do
      described_class.register!

      index_components = BetterPage.configuration.components_for(:index)
      expect(index_components).to include(:header)
      expect(index_components).to include(:table)
      expect(index_components).to include(:pagination)
      expect(index_components).to include(:statistics)
    end

    it "maps components to show page type" do
      described_class.register!

      show_components = BetterPage.configuration.components_for(:show)
      expect(show_components).to include(:header)
      expect(show_components).to include(:content_sections)
      expect(show_components).to include(:statistics)
    end

    it "maps components to form page type" do
      described_class.register!

      form_components = BetterPage.configuration.components_for(:form)
      expect(form_components).to include(:header)
      expect(form_components).to include(:panels)
      expect(form_components).to include(:errors)
    end

    it "maps components to custom page type" do
      described_class.register!

      custom_components = BetterPage.configuration.components_for(:custom)
      expect(custom_components).to include(:header)
      expect(custom_components).to include(:content)
      expect(custom_components).to include(:footer)
    end

    it "sets required components for index pages" do
      described_class.register!

      expect(BetterPage.configuration.component_required?(:index, :header)).to be true
      expect(BetterPage.configuration.component_required?(:index, :table)).to be true
    end

    it "sets required components for show pages" do
      described_class.register!

      expect(BetterPage.configuration.component_required?(:show, :header)).to be true
    end

    it "sets required components for form pages" do
      described_class.register!

      expect(BetterPage.configuration.component_required?(:form, :header)).to be true
      expect(BetterPage.configuration.component_required?(:form, :panels)).to be true
    end

    it "sets required components for custom pages" do
      described_class.register!

      expect(BetterPage.configuration.component_required?(:custom, :content)).to be true
    end

    it "registers header with schema" do
      described_class.register!

      header = BetterPage.configuration.component(:header)
      expect(header.schema).not_to be_nil
    end

    it "registers table with schema" do
      described_class.register!

      table = BetterPage.configuration.component(:table)
      expect(table.schema).not_to be_nil
    end

    it "registers alerts with default value" do
      described_class.register!

      alerts = BetterPage.configuration.component(:alerts)
      expect(alerts.default).to eq([])
    end

    it "registers pagination with default value" do
      described_class.register!

      pagination = BetterPage.configuration.component(:pagination)
      expect(pagination.default).to eq(enabled: false)
    end
  end
end
