# frozen_string_literal: true

require "better_page/version"
require "better_page/railtie" if defined?(Rails::Railtie)

module BetterPage
  # Core components
  autoload :ValidationError, "better_page/validation_error"
  autoload :ComponentRegistry, "better_page/component_registry"
  autoload :ComponentDefinition, "better_page/component_registry"
  autoload :Configuration, "better_page/configuration"
  autoload :DefaultComponents, "better_page/default_components"

  # Base page classes
  autoload :BasePage, "better_page/base_page"
  autoload :IndexBasePage, "better_page/index_base_page"
  autoload :ShowBasePage, "better_page/show_base_page"
  autoload :FormBasePage, "better_page/form_base_page"
  autoload :CustomBasePage, "better_page/custom_base_page"

  # Compliance module
  module Compliance
    autoload :Analyzer, "better_page/compliance/analyzer"
  end

  # ViewComponent classes (loaded from user's app/components directory)
  # These are defined when the user runs the install generator
  module Ui
    # UI components are autoloaded from the user's application
  end

  class << self
    # Access the global configuration
    #
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure BetterPage components
    #
    # @yield [Configuration] yields the configuration object
    # @return [Configuration]
    #
    # @example
    #   BetterPage.configure do |config|
    #     config.register_component :sidebar, default: { enabled: false }
    #     config.allow_components :index, :sidebar
    #   end
    #
    def configure
      yield(configuration)
      configuration
    end

    # Reset configuration to empty state
    # Used primarily for testing
    #
    # @return [void]
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Check if default components have been registered
    #
    # @return [Boolean]
    def defaults_registered?
      @defaults_registered ||= false
    end

    # Mark defaults as registered
    # Called by railtie after registering default components
    #
    # @return [void]
    def defaults_registered!
      @defaults_registered = true
    end
  end
end
