# frozen_string_literal: true

require "rails/generators"

module BetterPage
  module Generators
    # Generator to check for new components available in the BetterPage gem.
    #
    # Usage:
    #   rails g better_page:sync
    #
    # This compares the components registered in the gem's DefaultComponents
    # with those in your application's initializer and base page classes,
    # showing what's new and what might need updating.
    #
    class SyncGenerator < Rails::Generators::Base
      desc "Check for new components available in BetterPage gem"

      def check_components
        say ""
        say "BetterPage Sync Check", :green
        say "=" * 50
        say ""

        # Get gem's default component names
        gem_components = BetterPage::DefaultComponents.component_names

        # Get user's configured components
        user_components = BetterPage.configuration.component_names

        # Find differences
        new_in_gem = gem_components - user_components
        custom_in_user = user_components - gem_components

        if new_in_gem.empty? && custom_in_user.empty?
          say "Your configuration is up to date!", :green
          say ""
        else
          if new_in_gem.any?
            say "New components available from gem:", :yellow
            new_in_gem.each { |c| say "  + #{c}" }
            say ""
            say "These components are automatically available via global configuration."
            say "No action needed unless you want to customize their defaults."
            say ""
          end

          if custom_in_user.any?
            say "Custom components in your configuration:", :cyan
            custom_in_user.each { |c| say "  * #{c}" }
            say ""
          end
        end

        check_page_type_components
        check_base_page_files
      end

      private

      def check_page_type_components
        say "Page Type Component Mapping:", :green
        say "-" * 50

        %i[index show form custom].each do |page_type|
          gem_for_type = BetterPage.configuration.components_for(page_type)
          say "  #{page_type.to_s.ljust(10)} #{gem_for_type.join(', ')}"
        end

        say ""
      end

      def check_base_page_files
        say "Local Base Page Files:", :green
        say "-" * 50

        base_files = {
          "index_base_page.rb" => "app/pages/index_base_page.rb",
          "show_base_page.rb" => "app/pages/show_base_page.rb",
          "form_base_page.rb" => "app/pages/form_base_page.rb",
          "custom_base_page.rb" => "app/pages/custom_base_page.rb"
        }

        base_files.each do |name, path|
          full_path = Rails.root.join(path)
          if File.exist?(full_path)
            local_components = extract_local_components(full_path)
            if local_components.any?
              say "  #{name}: #{local_components.join(', ')}", :cyan
            else
              say "  #{name}: (no custom components)", :white
            end
          else
            say "  #{name}: NOT FOUND", :red
            say "    Run: rails g better_page:install", :yellow
          end
        end

        say ""
      end

      def extract_local_components(file_path)
        content = File.read(file_path)
        # Extract component names from register_component calls
        content.scan(/register_component\s+:(\w+)/).flatten.map(&:to_sym)
      end
    end
  end
end
