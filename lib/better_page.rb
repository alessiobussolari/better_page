# frozen_string_literal: true

require "better_page/version"
require "better_page/railtie" if defined?(Rails::Railtie)

module BetterPage
  # Core components
  autoload :ValidationError, "better_page/validation_error"
  autoload :ComponentRegistry, "better_page/component_registry"
  autoload :ComponentDefinition, "better_page/component_registry"

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
end
