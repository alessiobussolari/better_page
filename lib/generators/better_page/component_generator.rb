# frozen_string_literal: true

require "rails/generators"

module BetterPage
  module Generators
    class ComponentGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      argument :component_name, type: :string, required: true,
                                desc: "Name of the component to install (e.g., 'header', 'table', 'index')"

      desc "Installs a specific BetterPage ViewComponent"

      MAIN_COMPONENTS = %w[index show form custom].freeze
      UI_COMPONENTS = %w[
        header table alerts statistics pagination
        panel field errors overview content_section
        widget footer tabs drawer
      ].freeze

      def validate_component
        return if valid_component?

        say_error "Unknown component: #{component_name}"
        say ""
        say "Available main components: #{MAIN_COMPONENTS.join(', ')}"
        say "Available UI components: #{UI_COMPONENTS.join(', ')}"
        say ""
        say "Or use 'all' to install all components."
        raise Thor::Error, "Invalid component name"
      end

      def create_component_directories
        empty_directory "app/components/better_page"
        empty_directory "app/components/better_page/ui" if ui_component? || install_all?
      end

      def install_component
        if install_all?
          install_all_components
        elsif main_component?
          install_main_component
        else
          install_ui_component
        end
      end

      def show_post_install_message
        say ""
        say "Component(s) installed successfully!", :green
        say ""
        say "You can customize the components in app/components/better_page/"
        say ""
      end

      private

      def valid_component?
        install_all? || main_component? || ui_component?
      end

      def install_all?
        component_name.downcase == "all"
      end

      def main_component?
        MAIN_COMPONENTS.include?(normalized_name)
      end

      def ui_component?
        UI_COMPONENTS.include?(normalized_name)
      end

      def normalized_name
        @normalized_name ||= component_name.downcase.gsub(/_component$/, "").gsub(/_view_component$/, "")
      end

      def install_all_components
        MAIN_COMPONENTS.each { |name| copy_main_component(name) }
        UI_COMPONENTS.each { |name| copy_ui_component(name) }
      end

      def install_main_component
        copy_main_component(normalized_name)
      end

      def install_ui_component
        copy_ui_component(normalized_name)
      end

      def copy_main_component(name)
        template "view_components/#{name}_view_component.rb.tt",
                 "app/components/better_page/#{name}_view_component.rb"
        template "view_components/#{name}_view_component.html.erb.tt",
                 "app/components/better_page/#{name}_view_component.html.erb"
        say "  Installed: #{name}_view_component", :green
      end

      def copy_ui_component(name)
        template "view_components/ui/#{name}_component.rb.tt",
                 "app/components/better_page/ui/#{name}_component.rb"
        template "view_components/ui/#{name}_component.html.erb.tt",
                 "app/components/better_page/ui/#{name}_component.html.erb"
        say "  Installed: ui/#{name}_component", :green

        # Install dropdown controller if table component is installed
        install_dropdown_controller if name == "table"

        # Install drawer controller if drawer component is installed
        install_drawer_controller if name == "drawer"
      end

      def install_dropdown_controller
        return if File.exist?(Rails.root.join("app/javascript/controllers/dropdown_controller.js"))

        copy_file "javascript/controllers/dropdown_controller.js",
                  "app/javascript/controllers/dropdown_controller.js"
        say "  Installed: dropdown_controller.js (Stimulus)", :green
      end

      def install_drawer_controller
        return if File.exist?(Rails.root.join("app/javascript/controllers/drawer_controller.js"))

        copy_file "javascript/controllers/drawer_controller.js",
                  "app/javascript/controllers/drawer_controller.js"
        say "  Installed: drawer_controller.js (Stimulus)", :green
      end
    end
  end
end
