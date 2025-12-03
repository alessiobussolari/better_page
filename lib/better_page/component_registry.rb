# frozen_string_literal: true

require "dry-schema"
require "ostruct"

module BetterPage
  # Module that provides component registration DSL for page classes.
  #
  # Components can be registered at three levels:
  # 1. Global configuration (via BetterPage.configure in initializer)
  # 2. Class level (via register_component in base classes)
  # 3. Page type mapping (via page_type in base classes)
  #
  # @example Using page_type to inherit global components
  #   class IndexBasePage < ApplicationPage
  #     page_type :index  # Inherits components from BetterPage.configuration.components_for(:index)
  #   end
  #
  # @example Registering local components
  #   class MyPage < IndexBasePage
  #     register_component :custom_widget, default: nil
  #
  #     def custom_widget
  #       { data: @data }
  #     end
  #   end
  #
  module ComponentRegistry
    extend ActiveSupport::Concern

    included do
      class_attribute :registered_components, default: {}
      class_attribute :_page_type, default: nil
    end

    class_methods do
      # Set the page type for this class
      # This determines which global components are available
      #
      # @param type [Symbol] :index, :show, :form, or :custom
      # @return [Symbol]
      #
      # @example
      #   class IndexBasePage < ApplicationPage
      #     page_type :index
      #   end
      #
      def page_type(type = nil)
        if type
          self._page_type = type
        else
          _page_type
        end
      end

      # Register a component with optional schema validation
      # Local components are added to those from global configuration
      #
      # @param name [Symbol] the component name
      # @param required [Boolean] whether the component is required
      # @param default [Object] default value if component method is not defined
      # @yield optional dry-schema block for validation
      #
      # @example With schema
      #   register_component :header, required: true do
      #     required(:title).filled(:string)
      #   end
      #
      # @example Without schema
      #   register_component :alerts, default: []
      #
      def register_component(name, required: false, default: nil, &schema_block)
        schema = schema_block ? build_schema(&schema_block) : nil

        self.registered_components = registered_components.merge(
          name => ComponentDefinition.new(
            name: name,
            required: required,
            default: default,
            schema: schema
          )
        )
      end

      # Get all components available for this page class
      # Combines global configuration components with locally registered ones
      #
      # @return [Hash<Symbol, ComponentDefinition>]
      def effective_components
        result = {}

        # First, add components from global configuration for this page type
        if _page_type && BetterPage.defaults_registered?
          global_names = BetterPage.configuration.components_for(_page_type)
          global_names.each do |name|
            global_def = BetterPage.configuration.component(name)
            next unless global_def

            # Check if this component is required for this page type
            is_required = BetterPage.configuration.component_required?(_page_type, name)

            result[name] = ComponentDefinition.new(
              name: global_def.name,
              required: is_required,
              default: global_def.default,
              schema: global_def.schema
            )
          end
        end

        # Then, merge locally registered components (they override global ones)
        registered_components.each do |name, definition|
          result[name] = definition
        end

        result
      end

      # Get the list of component names available for this page class
      #
      # @return [Array<Symbol>]
      def allowed_component_names
        effective_components.keys
      end

      # Ensure subclasses inherit registered components
      def inherited(subclass)
        super
        subclass.registered_components = registered_components.dup
      end

      private

      def build_schema(&block)
        Dry::Schema.Params(&block)
      end
    end

    # Build the page by collecting and validating all registered components
    #
    # @return [BetterPage::Config] config object with components and metadata
    def build_page
      result = {}

      self.class.effective_components.each do |name, definition|
        value = resolve_component_value(name, definition)
        validate_component(name, value, definition)
        result[name] = value
      end

      BetterPage::Config.new(
        result,
        meta: {
          page_type: self.class.page_type,
          klass: view_component_class
        }
      )
    end

    # Build a single component for Turbo Frame
    # Returns a single component hash for lazy loading or navigation
    #
    # @param component_name [Symbol] the component to return
    # @return [Hash, nil] component configuration for Turbo Frame, or nil if not found/empty
    def frame_page(component_name)
      full_page = build_page
      return nil unless full_page.key?(component_name)

      value = full_page[component_name]
      return nil if skip_empty_component?(value)

      {
        component: component_name,
        config: value,
        klass: ui_component_class(component_name),
        target: frame_target(component_name)
      }
    end

    # Build multiple components for Turbo Streams
    # Returns an array of component hashes for real-time updates
    #
    # @param components [Array<Symbol>] specific components to return, or all if empty
    # @return [Array<Hash>] array of component configurations for Turbo Streams
    def stream_page(*components)
      full_page = build_page
      component_names = components.empty? ? stream_components : components.flatten

      component_names.filter_map do |name|
        next unless full_page.key?(name)

        value = full_page[name]
        next if skip_empty_component?(value)

        {
          component: name,
          config: value,
          klass: ui_component_class(name),
          target: stream_target(name)
        }
      end
    end

    # Get the ViewComponent class for this page type
    # Override in subclasses if using a custom component
    #
    # @return [Class] the ViewComponent class to use for rendering
    def view_component_class
      raise NotImplementedError, "Subclasses must implement #view_component_class"
    end

    # Get the UI ViewComponent class for a specific component
    #
    # @param name [Symbol] the component name
    # @return [Class, nil] the ViewComponent class or nil
    def ui_component_class(name)
      component_mapping[name]
    end

    # Components to include in stream_page by default
    # Override in subclasses to customize
    #
    # @return [Array<Symbol>] component names
    def stream_components
      self.class.effective_components.keys
    end

    # Get the Turbo Frame target for a component
    #
    # @param name [Symbol] the component name
    # @return [String] the target ID for turbo-frame
    def frame_target(name)
      "better_page_#{name}"
    end

    # Get the Turbo Stream target for a component
    #
    # @param name [Symbol] the component name
    # @return [String] the target ID for turbo-stream
    def stream_target(name)
      "better_page_#{name}"
    end

    # Dynamic frame_* and stream_* method support
    # Allows calling frame_<action> or stream_<action> for any action method defined on the page
    #
    # @example Turbo Frame (single component, lazy loading)
    #   page.frame_index(:table)  # calls frame_page(:table) for IndexBasePage
    #   page.frame_show(:header)  # calls frame_page(:header) for ShowBasePage
    #   page.frame_daily(:chart)  # calls frame_page(:chart) for a custom DailyPage
    #
    # @example Turbo Stream (multiple components, real-time updates)
    #   page.stream_index                        # all stream components
    #   page.stream_index(:table, :statistics)   # specific components
    #   page.stream_daily(:chart, :summary)      # for custom DailyPage
    #
    def method_missing(method_name, *args, &block)
      method_str = method_name.to_s

      if method_str.start_with?("frame_")
        action_name = method_str.sub("frame_", "")
        if respond_to?(action_name, true)
          frame_page(*args)
        else
          super
        end
      elsif method_str.start_with?("stream_")
        action_name = method_str.sub("stream_", "")
        if respond_to?(action_name, true)
          stream_page(*args)
        else
          super
        end
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_str = method_name.to_s

      if method_str.start_with?("frame_") || method_str.start_with?("stream_")
        prefix = method_str.start_with?("frame_") ? "frame_" : "stream_"
        action_name = method_str.sub(prefix, "")
        respond_to?(action_name, true) || super
      else
        super
      end
    end

    private

    # Mapping of component names to their ViewComponent classes
    # Override in subclasses to customize
    #
    # @return [Hash<Symbol, Class>]
    def component_mapping
      {
        header: defined?(BetterPage::Ui::HeaderComponent) ? BetterPage::Ui::HeaderComponent : nil,
        table: defined?(BetterPage::Ui::TableComponent) ? BetterPage::Ui::TableComponent : nil,
        alerts: defined?(BetterPage::Ui::AlertsComponent) ? BetterPage::Ui::AlertsComponent : nil,
        statistics: defined?(BetterPage::Ui::StatisticsComponent) ? BetterPage::Ui::StatisticsComponent : nil,
        pagination: defined?(BetterPage::Ui::PaginationComponent) ? BetterPage::Ui::PaginationComponent : nil,
        details: defined?(BetterPage::Ui::DetailsComponent) ? BetterPage::Ui::DetailsComponent : nil,
        tabs: defined?(BetterPage::Ui::TabsComponent) ? BetterPage::Ui::TabsComponent : nil,
        footer: defined?(BetterPage::Ui::FooterComponent) ? BetterPage::Ui::FooterComponent : nil,
        panel: defined?(BetterPage::Ui::PanelComponent) ? BetterPage::Ui::PanelComponent : nil,
        errors: defined?(BetterPage::Ui::ErrorsComponent) ? BetterPage::Ui::ErrorsComponent : nil,
        content_section: defined?(BetterPage::Ui::ContentSectionComponent) ? BetterPage::Ui::ContentSectionComponent : nil,
        widget: defined?(BetterPage::Ui::WidgetComponent) ? BetterPage::Ui::WidgetComponent : nil
      }
    end

    def skip_empty_component?(value)
      return true if value.nil?
      return true if value.is_a?(Array) && value.empty?
      return true if value.is_a?(Hash) && value[:enabled] == false

      false
    end

    def resolve_component_value(name, definition)
      if respond_to?(name, true)
        send(name)
      else
        definition.default
      end
    end

    def validate_component(name, value, definition)
      # Check required
      if definition.required? && value.nil?
        handle_validation_error("Component :#{name} is required but returned nil")
      end

      # Schema validation
      return unless definition.schema && value

      # Handle array schemas vs hash schemas
      validation_result = if value.is_a?(Array)
                            validate_array(value, definition.schema)
      else
                            definition.schema.call(value)
      end

      return if validation_result.success?

      handle_validation_error(
        "Component :#{name} validation failed: #{validation_result.errors.to_h}"
      )
    end

    def validate_array(array, schema)
      errors = {}
      array.each_with_index do |item, index|
        result = schema.call(item)
        errors[index] = result.errors.to_h unless result.success?
      end

      if errors.empty?
        Dry::Schema::Result.new(array, message_compiler: nil) { |r| r.success(array) }
      else
        # Return a failure-like object
        OpenStruct.new(success?: false, errors: OpenStruct.new(to_h: errors))
      end
    end

    def handle_validation_error(message)
      if defined?(Rails) && Rails.env.development?
        raise BetterPage::ValidationError, message
      elsif defined?(Rails)
        Rails.logger.warn "[BetterPage] #{message}"
      else
        warn "[BetterPage] #{message}"
      end
    end
  end

  # Value object representing a registered component
  class ComponentDefinition
    attr_reader :name, :default, :schema

    def initialize(name:, required:, default:, schema:)
      @name = name
      @required = required
      @default = default
      @schema = schema
    end

    def required?
      @required
    end
  end
end
