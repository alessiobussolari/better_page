# frozen_string_literal: true

require "dry-schema"

module BetterPage
  # Central configuration for BetterPage components.
  # Allows registering components globally and mapping them to page types.
  #
  # @example Register components in initializer
  #   BetterPage.configure do |config|
  #     config.register_component :sidebar, default: { enabled: false }
  #     config.allow_components :index, :sidebar
  #   end
  #
  class Configuration
    attr_reader :components, :page_type_components, :required_components

    def initialize
      @components = {}
      @page_type_components = {
        index: [],
        show: [],
        form: [],
        custom: []
      }
      @required_components = {
        index: [],
        show: [],
        form: [],
        custom: []
      }
    end

    # Register a component with optional schema validation
    #
    # @param name [Symbol] the component name
    # @param required [Boolean] whether the component is required by default
    # @param default [Object] default value if component method is not defined
    # @yield optional dry-schema block for validation
    # @return [ComponentDefinition]
    #
    # @example With schema
    #   config.register_component :header, required: true do
    #     required(:title).filled(:string)
    #   end
    #
    # @example Without schema
    #   config.register_component :alerts, default: []
    #
    def register_component(name, required: false, default: nil, &schema_block)
      schema = schema_block ? Dry::Schema.Params(&schema_block) : nil

      @components[name] = ComponentDefinition.new(
        name: name,
        required: required,
        default: default,
        schema: schema
      )
    end

    # Map components to a page type
    # If called multiple times, appends to existing components
    #
    # @param page_type [Symbol] :index, :show, :form, or :custom
    # @param names [Array<Symbol>] component names to allow
    # @return [Array<Symbol>] updated component list
    #
    # @example
    #   config.allow_components :index, :header, :table, :pagination
    #
    def allow_components(page_type, *names)
      @page_type_components[page_type] ||= []
      @page_type_components[page_type].concat(names.flatten)
      @page_type_components[page_type].uniq!
      @page_type_components[page_type]
    end

    # Mark components as required for a specific page type
    #
    # @param page_type [Symbol] :index, :show, :form, or :custom
    # @param names [Array<Symbol>] component names to mark as required
    # @return [Array<Symbol>] updated required component list
    #
    # @example
    #   config.require_components :index, :header, :table
    #
    def require_components(page_type, *names)
      @required_components[page_type] ||= []
      @required_components[page_type].concat(names.flatten)
      @required_components[page_type].uniq!
      @required_components[page_type]
    end

    # Get components allowed for a specific page type
    #
    # @param page_type [Symbol] :index, :show, :form, or :custom
    # @return [Array<Symbol>] allowed component names
    def components_for(page_type)
      @page_type_components[page_type] || []
    end

    # Check if a component is required for a specific page type
    #
    # @param page_type [Symbol] :index, :show, :form, or :custom
    # @param name [Symbol] component name
    # @return [Boolean]
    def component_required?(page_type, name)
      required_list = @required_components[page_type] || []
      return true if required_list.include?(name)

      # Fallback to component's default required status
      @components[name]&.required? || false
    end

    # Get a component definition by name
    #
    # @param name [Symbol] component name
    # @return [ComponentDefinition, nil]
    def component(name)
      @components[name]
    end

    # Get all registered component names
    #
    # @return [Array<Symbol>]
    def component_names
      @components.keys
    end

    # Reset configuration to empty state
    # Used primarily for testing
    def reset!
      @components = {}
      @page_type_components = { index: [], show: [], form: [], custom: [] }
      @required_components = { index: [], show: [], form: [], custom: [] }
    end

    # Deep copy for inheritance
    def dup
      copy = super
      copy.instance_variable_set(:@components, @components.dup)
      copy.instance_variable_set(:@page_type_components, deep_dup(@page_type_components))
      copy.instance_variable_set(:@required_components, deep_dup(@required_components))
      copy
    end

    private

    def deep_dup(hash)
      hash.transform_values { |v| v.is_a?(Array) ? v.dup : v }
    end
  end
end
