# frozen_string_literal: true

module BetterPage
  # Config wrapper for page configurations
  #
  # Provides a standardized way to return both components and metadata from pages.
  # Follows the same pattern as BetterService::Result and BetterController::Result.
  #
  # @example Basic usage
  #   config = page.index
  #   config.header[:title]
  #   config[:header][:title]  # also works
  #
  # @example Destructuring
  #   components, meta = page.index
  #
  class Config
    attr_reader :components, :meta

    # @param components [Hash] Hash of component configurations
    # @param meta [Hash] Metadata hash (page_type, klass, etc.)
    def initialize(components, meta: {})
      @components = components
      @meta = meta.is_a?(Hash) ? meta.reverse_merge(page_type: nil, klass: nil) : { page_type: nil, klass: nil }
    end

    # Component accessors
    # @return [Hash, Array, nil] the component configuration
    def header
      components[:header]
    end

    def table
      components[:table]
    end

    def statistics
      components[:statistics]
    end

    def alerts
      components[:alerts]
    end

    def tabs
      components[:tabs]
    end

    def pagination
      components[:pagination]
    end

    def details
      components[:details]
    end

    def footer
      components[:footer]
    end

    def panel
      components[:panel]
    end

    def errors
      components[:errors]
    end

    def content_section
      components[:content_section]
    end

    def widget
      components[:widget]
    end

    # Meta accessors
    # @return [Symbol, nil] the page type (:index, :show, :form, :custom)
    def page_type
      meta[:page_type]
    end

    # @return [Class, nil] the ViewComponent class for rendering
    def klass
      meta[:klass]
    end

    # Supports destructuring: components, meta = config
    # @return [Array] [components, meta]
    def to_ary
      [ components, meta ]
    end

    # Alias for destructuring compatibility
    alias_method :deconstruct, :to_ary

    # Hash-like access for compatibility
    # @param key [Symbol] The key to access
    # @return [Object, nil] The value associated with the key
    def [](key)
      if components.key?(key)
        components[key]
      else
        meta[key]
      end
    end

    # Nested Hash-like access (dig)
    # @param keys [Array<Symbol>] Keys for nested access
    # @return [Object, nil] The nested value
    def dig(*keys)
      return nil if keys.empty?

      value = self[keys.first]
      return value if keys.size == 1
      return nil unless value.respond_to?(:dig)

      value.dig(*keys[1..])
    end

    # Check if key exists
    # @param key [Symbol] The key to check
    # @return [Boolean]
    def key?(key)
      components.key?(key) || meta.key?(key)
    end
    alias_method :has_key?, :key?

    # Convert to hash for compatibility
    # @return [Hash] Full hash representation
    def to_h
      { components: components, meta: meta }
    end

    # List of available component names
    # @return [Array<Symbol>]
    def component_names
      components.keys
    end

    # Check if a component is present and not empty
    # @param name [Symbol] The component name
    # @return [Boolean]
    def component?(name)
      value = components[name]
      return false if value.nil?
      return false if value.is_a?(Array) && value.empty?
      return false if value.is_a?(Hash) && value[:enabled] == false

      true
    end

    # Iterate over components
    # @yield [name, value] Block to execute for each component
    def each_component(&block)
      components.each(&block)
    end

    # Get components that are present (not nil/empty)
    # @return [Hash] Hash of present components
    def present_components
      components.select { |name, _| component?(name) }
    end
  end
end
