# frozen_string_literal: true

require "rails/generators"

module BetterPage
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates the app/pages directory and ApplicationPage base class"

      def create_pages_directory
        empty_directory "app/pages"
      end

      def create_application_page
        template "application_page.rb.tt", "app/pages/application_page.rb"
      end

      def show_post_install_message
        say ""
        say "BetterPage has been installed successfully!", :green
        say ""
        say "You can now generate pages using:"
        say "  rails g better_page:page Namespace::Resource index show new edit"
        say ""
        say "Example:"
        say "  rails g better_page:page Admin::Users index show new edit"
        say ""
      end
    end
  end
end
