# frozen_string_literal: true

require "rails/generators"

module BetterPage
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates the app/pages directory, ApplicationPage base class, base page classes, initializer, and ViewComponents"

      class_option :skip_components, type: :boolean, default: false,
                                     desc: "Skip installing ViewComponents"

      def create_pages_directory
        empty_directory "app/pages"
      end

      def create_initializer
        template "better_page_initializer.rb.tt", "config/initializers/better_page.rb"
      end

      def create_application_page
        template "application_page.rb.tt", "app/pages/application_page.rb"
      end

      def create_base_pages
        template "index_base_page.rb.tt", "app/pages/index_base_page.rb"
        template "show_base_page.rb.tt", "app/pages/show_base_page.rb"
        template "form_base_page.rb.tt", "app/pages/form_base_page.rb"
        template "custom_base_page.rb.tt", "app/pages/custom_base_page.rb"
      end

      def create_view_components
        return if options[:skip_components]

        # Create main directory structure
        empty_directory "app/components/better_page"
        empty_directory "app/components/better_page/ui"

        # Copy base component first (all components inherit from this)
        template "view_components/application_view_component.rb.tt",
                 "app/components/better_page/application_view_component.rb"

        # Copy main view components
        copy_view_component "index_view_component"
        copy_view_component "show_view_component"
        copy_view_component "form_view_component"
        copy_view_component "custom_view_component"

        # Copy UI components
        ui_components.each do |component|
          copy_ui_component component
        end
      end

      def create_stimulus_controllers
        return if options[:skip_components]

        # Create directory for BetterPage controllers
        empty_directory "app/javascript/controllers/better_page"

        # Copy Stimulus controllers for interactive components
        copy_file "javascript/controllers/dropdown_controller.js",
                  "app/javascript/controllers/better_page/dropdown_controller.js"
        copy_file "javascript/controllers/index.js",
                  "app/javascript/controllers/better_page/index.js"

        # Add import to the main controllers/index.js if it exists
        controllers_index = "app/javascript/controllers/index.js"
        if File.exist?(Rails.root.join(controllers_index))
          append_to_file controllers_index, <<~JS

            // BetterPage controllers
            import { registerBetterPageControllers } from "./better_page"
            registerBetterPageControllers(application)
          JS
        end
      end

      def show_post_install_message
        say ""
        say "BetterPage has been installed successfully!", :green
        say ""
        say "Created:"
        say "  - config/initializers/better_page.rb (component configuration)"
        say "  - app/pages/application_page.rb"
        say "  - app/pages/index_base_page.rb"
        say "  - app/pages/show_base_page.rb"
        say "  - app/pages/form_base_page.rb"
        say "  - app/pages/custom_base_page.rb"
        unless options[:skip_components]
          say "  - app/components/better_page/application_view_component.rb (base component)"
          say "  - app/components/better_page/ (ViewComponents)"
          say "  - app/javascript/controllers/better_page/ (Stimulus controllers)"
          say ""
          say "ViewComponents and Stimulus controllers have been copied to your project."
          say "You can customize them to match your design system."
          say ""
          say "Note: Make sure you have @hotwired/stimulus installed."
          say ""
          say "Alternative: Install via npm instead of copying files:"
          say "  npm install better-page-stimulus"
          say "  # or"
          say "  yarn add better-page-stimulus"
        end
        say ""
        say "Base page classes in app/pages/ can be customized:"
        say "  - Add custom components with register_component"
        say "  - Override helper methods"
        say "  - Customize stream_components"
        say ""
        say "You can now generate pages using:"
        say "  rails g better_page:page Namespace::Resource index show new edit"
        say ""
        say "Example:"
        say "  rails g better_page:page Admin::Users index show new edit"
        say ""
        say "To check for gem updates:"
        say "  rails g better_page:sync"
        say ""
        say "To add individual components later:"
        say "  rails g better_page:component ComponentName"
        say ""
      end

      private

      def copy_view_component(name)
        template "view_components/#{name}.rb.tt", "app/components/better_page/#{name}.rb"
        template "view_components/#{name}.html.erb.tt", "app/components/better_page/#{name}.html.erb"
      end

      def copy_ui_component(name)
        template "view_components/ui/#{name}_component.rb.tt",
                 "app/components/better_page/ui/#{name}_component.rb"
        template "view_components/ui/#{name}_component.html.erb.tt",
                 "app/components/better_page/ui/#{name}_component.html.erb"
      end

      def ui_components
        %w[
          header
          table
          alerts
          statistics
          pagination
          panel
          field
          errors
          overview
          content_section
          widget
          footer
          tabs
        ]
      end
    end
  end
end
