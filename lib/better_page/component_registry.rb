# frozen_string_literal: true

require "dry-schema"

module BetterPage
  # Module that provides component registration DSL for page classes.
  #
  # Components are registered at the class level with optional schema validation.
  # Each component can be required or optional, with a default value.
  #
  # @example Registering components
  #   class MyPage < BetterPage::BasePage
  #     register_component :header, required: true do
  #       required(:title).filled(:string)
  #       optional(:breadcrumbs).array(:hash)
  #     end
  #
  #     register_component :footer, default: { enabled: false }
  #
  #     def header
  #       { title: "My Page", breadcrumbs: [] }
  #     end
  #   end
  #
  module ComponentRegistry
    extend ActiveSupport::Concern

    included do
      class_attribute :registered_components, default: {}
    end

    class_methods do
      # Register a component with optional schema validation
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
    # @return [Hash] hash with all component values
    def build_page
      result = {}

      self.class.registered_components.each do |name, definition|
        value = resolve_component_value(name, definition)
        validate_component(name, value, definition)
        result[name] = value
      end

      result
    end

    private

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
