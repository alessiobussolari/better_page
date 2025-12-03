# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::ComponentRegistry do
  # Mock ViewComponent class for testing
  let(:mock_view_component) { Class.new }

  let(:test_page_class) do
    mock_component = mock_view_component
    Class.new do
      include BetterPage::ComponentRegistry

      register_component :header, required: true do
        required(:title).filled(:string)
        optional(:subtitle).filled(:string)
      end

      register_component :footer, default: { enabled: false }
      register_component :sidebar, default: nil

      define_method(:initialize) do |header_data = nil|
        @header_data = header_data
      end

      define_method(:header) do
        @header_data || { title: "Default Title" }
      end

      define_method(:view_component_class) do
        mock_component
      end
    end
  end

  let(:child_page_class) do
    parent = test_page_class
    Class.new(parent) do
      register_component :extra, default: { data: "child" }

      def extra
        { data: "custom" }
      end
    end
  end

  describe "component registration" do
    it "registers components with class attribute" do
      expect(test_page_class.registered_components).to have_key(:header)
      expect(test_page_class.registered_components).to have_key(:footer)
      expect(test_page_class.registered_components).to have_key(:sidebar)
    end

    it "component definition stores required flag" do
      header_def = test_page_class.registered_components[:header]
      footer_def = test_page_class.registered_components[:footer]

      expect(header_def.required?).to be true
      expect(footer_def.required?).to be false
    end

    it "component definition stores default value" do
      footer_def = test_page_class.registered_components[:footer]
      sidebar_def = test_page_class.registered_components[:sidebar]

      expect(footer_def.default).to eq({ enabled: false })
      expect(sidebar_def.default).to be_nil
    end

    it "component definition stores schema" do
      header_def = test_page_class.registered_components[:header]
      footer_def = test_page_class.registered_components[:footer]

      expect(header_def.schema).not_to be_nil
      expect(footer_def.schema).to be_nil
    end
  end

  describe "#build_page" do
    it "collects all component values" do
      page = test_page_class.new({ title: "My Title" })
      result = page.build_page

      expect(result[:header]).to eq({ title: "My Title" })
      expect(result[:footer]).to eq({ enabled: false })
      expect(result[:sidebar]).to be_nil
    end

    it "uses default when method not defined" do
      page = test_page_class.new
      result = page.build_page

      expect(result[:footer]).to eq({ enabled: false })
    end

    it "includes klass for self-rendering" do
      page = test_page_class.new({ title: "Test" })
      result = page.build_page

      expect(result).to have_key(:klass)
      expect(result[:klass]).to eq(mock_view_component)
    end
  end

  describe "inheritance" do
    it "child class inherits parent components" do
      expect(child_page_class.registered_components).to have_key(:header)
      expect(child_page_class.registered_components).to have_key(:footer)
      expect(child_page_class.registered_components).to have_key(:extra)
    end

    it "child class can override inherited components" do
      page = child_page_class.new
      result = page.build_page

      expect(result[:extra]).to eq({ data: "custom" })
    end
  end

  describe "validation" do
    it "passes for valid data" do
      page = test_page_class.new({ title: "Valid Title" })
      result = page.build_page
      expect(result[:header][:title]).to eq("Valid Title")
    end

    it "validates required components" do
      klass = Class.new do
        include BetterPage::ComponentRegistry

        register_component :required_field, required: true

        def required_field
          nil
        end

        def view_component_class
          Class.new
        end
      end

      page = klass.new
      result = page.build_page
      expect(result[:required_field]).to be_nil
    end
  end

  describe "#stream_page" do
    it "returns array of component configurations" do
      page = test_page_class.new({ title: "Test" })
      result = page.stream_page

      expect(result).to be_an(Array)
    end

    it "filters by component name" do
      page = test_page_class.new({ title: "Test" })
      result = page.stream_page(:header)

      component_names = result.map { |c| c[:component] }
      expect(component_names).to include(:header)
      expect(component_names).not_to include(:footer)
    end

    it "includes target for turbo streams" do
      page = test_page_class.new({ title: "Test" })
      result = page.stream_page(:header)

      header_component = result.find { |c| c[:component] == :header }
      expect(header_component).not_to be_nil
      expect(header_component[:target]).to eq("better_page_header")
    end
  end

  describe "#frame_page" do
    it "returns single component configuration" do
      page = test_page_class.new({ title: "Test" })
      result = page.frame_page(:header)

      expect(result).to be_a(Hash)
      expect(result[:component]).to eq(:header)
      expect(result[:config]).to eq({ title: "Test" })
      expect(result[:target]).to eq("better_page_header")
    end

    it "returns nil for non-existent component" do
      page = test_page_class.new({ title: "Test" })
      result = page.frame_page(:nonexistent)

      expect(result).to be_nil
    end

    it "returns nil for empty component" do
      page = test_page_class.new({ title: "Test" })
      result = page.frame_page(:sidebar)

      expect(result).to be_nil
    end
  end

  describe "dynamic frame_* and stream_* methods" do
    let(:dynamic_page_class) do
      mock_component = mock_view_component
      Class.new do
        include BetterPage::ComponentRegistry

        register_component :data, default: { items: [] }
        register_component :chart, default: { type: :bar }

        def daily
          build_page
        end

        define_method(:view_component_class) do
          mock_component
        end
      end
    end

    it "dynamic stream method works for custom action" do
      page = dynamic_page_class.new
      expect(page.respond_to?(:stream_daily)).to be true
      result = page.stream_daily
      expect(result).to be_an(Array)
    end

    it "dynamic stream method with components filter" do
      page = dynamic_page_class.new
      result = page.stream_daily(:data)
      expect(result.size).to eq(1)
      expect(result.first[:component]).to eq(:data)
    end

    it "dynamic frame method works for custom action" do
      page = dynamic_page_class.new
      expect(page.respond_to?(:frame_daily)).to be true
      result = page.frame_daily(:data)
      expect(result).to be_a(Hash)
      expect(result[:component]).to eq(:data)
    end

    it "dynamic frame method raises for non-existent action" do
      page = dynamic_page_class.new
      expect(page.respond_to?(:frame_nonexistent)).to be false
      expect { page.frame_nonexistent(:data) }.to raise_error(NoMethodError)
    end

    it "dynamic stream method raises for non-existent action" do
      page = dynamic_page_class.new
      expect(page.respond_to?(:stream_nonexistent)).to be false
      expect { page.stream_nonexistent }.to raise_error(NoMethodError)
    end

    it "respond_to? works for dynamic frame methods" do
      page = dynamic_page_class.new
      expect(page.respond_to?(:frame_daily)).to be true
      expect(page.respond_to?(:frame_weekly)).to be false
    end

    it "respond_to? works for dynamic stream methods" do
      page = dynamic_page_class.new
      expect(page.respond_to?(:stream_daily)).to be true
      expect(page.respond_to?(:stream_weekly)).to be false
    end
  end
end

RSpec.describe BetterPage::ComponentDefinition do
  describe "initialization" do
    it "creates component definition with all attributes" do
      definition = BetterPage::ComponentDefinition.new(
        name: :test,
        required: true,
        default: { foo: "bar" },
        schema: nil
      )

      expect(definition.name).to eq(:test)
      expect(definition.required?).to be true
      expect(definition.default).to eq({ foo: "bar" })
      expect(definition.schema).to be_nil
    end

    it "required? returns false by default" do
      definition = BetterPage::ComponentDefinition.new(
        name: :test,
        required: false,
        default: nil,
        schema: nil
      )

      expect(definition.required?).to be false
    end
  end
end

RSpec.describe "ComponentRegistry additional coverage" do
  let(:mock_view_component) { Class.new }

  describe "#page_type getter" do
    it "returns nil when page_type not set" do
      klass = Class.new do
        include BetterPage::ComponentRegistry
      end

      expect(klass.page_type).to be_nil
    end

    it "returns the set page type" do
      klass = Class.new do
        include BetterPage::ComponentRegistry
        page_type :index
      end

      expect(klass.page_type).to eq(:index)
    end
  end

  describe "#allowed_component_names" do
    it "returns list of component names" do
      klass = Class.new do
        include BetterPage::ComponentRegistry
        register_component :header, required: true
        register_component :footer, default: nil
      end

      expect(klass.allowed_component_names).to contain_exactly(:header, :footer)
    end
  end

  describe "#ui_component_class" do
    it "returns nil for unmapped component" do
      mock_component = mock_view_component
      klass = Class.new do
        include BetterPage::ComponentRegistry
        register_component :custom, default: nil

        define_method(:view_component_class) { mock_component }
      end

      page = klass.new
      expect(page.ui_component_class(:custom)).to be_nil
    end
  end

  describe "#stream_components default" do
    it "returns all effective component keys by default" do
      mock_component = mock_view_component
      klass = Class.new do
        include BetterPage::ComponentRegistry
        register_component :header, required: true
        register_component :footer, default: nil

        def header
          { title: "Test" }
        end

        define_method(:view_component_class) { mock_component }
      end

      page = klass.new
      expect(page.stream_components).to contain_exactly(:header, :footer)
    end
  end

  describe "validation with array schema" do
    it "handles validation errors in array items" do
      mock_component = mock_view_component
      klass = Class.new do
        include BetterPage::ComponentRegistry

        register_component :items, required: true do
          required(:name).filled(:string)
        end

        def items
          [ { name: 123 } ] # Invalid - name should be string
        end

        define_method(:view_component_class) { mock_component }
      end

      page = klass.new
      # In development mode, this should raise or log
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      expect { page.build_page }.to raise_error(BetterPage::ValidationError)
    end
  end

  describe "handle_validation_error" do
    it "logs warning in production" do
      mock_component = mock_view_component
      klass = Class.new do
        include BetterPage::ComponentRegistry

        register_component :field, required: true

        def field
          nil
        end

        define_method(:view_component_class) { mock_component }
      end

      page = klass.new
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      expect(Rails.logger).to receive(:warn).with(/required but returned nil/)

      page.build_page
    end
  end

  describe "skip_empty_component" do
    let(:mock_component) { Class.new }

    it "skips nil components in stream_page" do
      klass = Class.new do
        include BetterPage::ComponentRegistry

        register_component :header, default: { title: "Test" }
        register_component :sidebar, default: nil

        define_method(:view_component_class) { Class.new }
      end

      page = klass.new
      result = page.stream_page(:header, :sidebar)

      # sidebar should be skipped because it's nil
      expect(result.map { |c| c[:component] }).to contain_exactly(:header)
    end

    it "skips empty array components in stream_page" do
      klass = Class.new do
        include BetterPage::ComponentRegistry

        register_component :header, default: { title: "Test" }
        register_component :alerts, default: []

        define_method(:view_component_class) { Class.new }
      end

      page = klass.new
      result = page.stream_page(:header, :alerts)

      # alerts should be skipped because it's empty array
      expect(result.map { |c| c[:component] }).to contain_exactly(:header)
    end

    it "skips disabled components in stream_page" do
      klass = Class.new do
        include BetterPage::ComponentRegistry

        register_component :header, default: { title: "Test" }
        register_component :footer, default: { enabled: false }

        define_method(:view_component_class) { Class.new }
      end

      page = klass.new
      result = page.stream_page(:header, :footer)

      # footer should be skipped because enabled: false
      expect(result.map { |c| c[:component] }).to contain_exactly(:header)
    end
  end

  describe "frame_page with disabled component" do
    it "returns nil for disabled component" do
      klass = Class.new do
        include BetterPage::ComponentRegistry

        register_component :footer, default: { enabled: false }

        define_method(:view_component_class) { Class.new }
      end

      page = klass.new
      expect(page.frame_page(:footer)).to be_nil
    end
  end
end
