# frozen_string_literal: true

require "rails/generators"

module BetterPage
  module Generators
    class PageGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      argument :resource, type: :string, required: true,
               desc: "The resource name (e.g., Admin::Users or Users)"
      argument :actions, type: :array, default: [],
               desc: "The actions to generate (index, show, new, edit, custom)"

      desc "Generates page classes for the specified resource and actions"

      def check_pages_directory
        unless File.directory?(Rails.root.join("app", "pages"))
          say "app/pages directory not found. Run 'rails g better_page:install' first.", :red
          exit 1
        end
      end

      def create_page_files
        actions_to_generate = actions.empty? ? %w[index show new edit] : actions

        actions_to_generate.each do |action|
          template_name = template_for_action(action)
          if template_name
            template "#{template_name}.rb.tt", page_path(action)
          else
            say "Unknown action: #{action}. Skipping.", :yellow
          end
        end
      end

      def show_completion_message
        say ""
        say "Pages generated successfully!", :green
        say ""
      end

      private

      def template_for_action(action)
        case action.to_s
        when "index" then "index_page"
        when "show" then "show_page"
        when "new" then "new_page"
        when "edit" then "edit_page"
        when "custom" then "custom_page"
        end
      end

      def page_path(action)
        File.join("app", "pages", *namespace_path, "#{action}_page.rb")
      end

      def namespace_path
        resource.underscore.split("/")
      end

      def resource_namespace
        parts = resource.split("::")
        parts.length > 1 ? parts[0..-2].join("::") : nil
      end

      def resource_name
        resource.split("::").last
      end

      def resource_singular
        resource_name.singularize.underscore
      end

      def resource_plural
        resource_name.pluralize.underscore
      end

      def full_class_name(action)
        parts = resource.split("::")
        parts << "#{action.to_s.camelize}Page"
        parts.join("::")
      end

      def module_nesting_start
        parts = resource.split("::")
        parts.map { |part| "module #{part}" }.join("\n  ")
      end

      def module_nesting_end
        parts = resource.split("::")
        parts.map { "end" }.join("\n")
      end

      def class_indent
        "  " * resource.split("::").length
      end
    end
  end
end
