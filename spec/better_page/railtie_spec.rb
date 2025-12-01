# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::Railtie do
  describe "initializers" do
    it "registers default components" do
      # The railtie has already run by the time tests execute
      expect(BetterPage.defaults_registered?).to be true
    end

    it "configures default components globally" do
      # Verify that default components are available
      expect(BetterPage.configuration.component(:header)).not_to be_nil
      expect(BetterPage.configuration.component(:table)).not_to be_nil
      expect(BetterPage.configuration.component(:footer)).not_to be_nil
    end

    it "maps components to page types" do
      expect(BetterPage.configuration.components_for(:index)).not_to be_empty
      expect(BetterPage.configuration.components_for(:show)).not_to be_empty
      expect(BetterPage.configuration.components_for(:form)).not_to be_empty
      expect(BetterPage.configuration.components_for(:custom)).not_to be_empty
    end
  end

  describe "autoload paths" do
    it "adds app/pages to autoload paths when directory exists" do
      pages_path = Rails.root.join("app", "pages").to_s

      # Check if the path is in autoload_paths
      autoload_paths = Rails.application.config.autoload_paths

      # The path should be in autoload paths if it exists
      if File.directory?(pages_path)
        expect(autoload_paths).to include(pages_path)
      end
    end

    it "adds app/pages to eager_load paths when directory exists" do
      pages_path = Rails.root.join("app", "pages").to_s

      eager_load_paths = Rails.application.config.eager_load_paths

      if File.directory?(pages_path)
        expect(eager_load_paths).to include(pages_path)
      end
    end
  end

  describe "generators" do
    it "defines InstallGenerator" do
      expect(defined?(BetterPage::Generators::InstallGenerator)).to be_truthy
    end

    it "defines PageGenerator" do
      expect(defined?(BetterPage::Generators::PageGenerator)).to be_truthy
    end

    it "defines SyncGenerator" do
      expect(defined?(BetterPage::Generators::SyncGenerator)).to be_truthy
    end
  end

  describe "rake tasks" do
    it "loads rake tasks file" do
      task_file = File.expand_path("../../lib/tasks/better_page.rake", __dir__)
      expect(File.exist?(task_file)).to be true
    end
  end
end
