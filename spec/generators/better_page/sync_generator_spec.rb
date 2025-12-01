# frozen_string_literal: true

require "rails_helper"
require "generators/better_page/sync_generator"
require "fileutils"

RSpec.describe BetterPage::Generators::SyncGenerator, type: :generator do
  let(:destination) { File.expand_path("../../../tmp/generator_test", __dir__) }

  before do
    FileUtils.rm_rf(destination)
    FileUtils.mkdir_p(destination)
  end

  after do
    FileUtils.rm_rf(destination)
  end

  describe "description" do
    it "has a description" do
      expect(described_class.desc).to include("Check for new components")
    end
  end

  describe "#check_components" do
    let(:generator) { described_class.new([], {}, destination_root: destination) }

    before do
      # Stub output methods
      allow(generator).to receive(:say)
    end

    it "displays sync check header" do
      allow(generator).to receive(:check_page_type_components)
      allow(generator).to receive(:check_base_page_files)

      generator.check_components

      expect(generator).to have_received(:say).with("BetterPage Sync Check", :green)
    end

    it "calls check_page_type_components" do
      allow(generator).to receive(:check_page_type_components)
      allow(generator).to receive(:check_base_page_files)

      generator.check_components

      expect(generator).to have_received(:check_page_type_components)
    end

    it "calls check_base_page_files" do
      allow(generator).to receive(:check_page_type_components)
      allow(generator).to receive(:check_base_page_files)

      generator.check_components

      expect(generator).to have_received(:check_base_page_files)
    end
  end

  describe "#check_page_type_components" do
    let(:generator) { described_class.new([], {}, destination_root: destination) }

    before do
      allow(generator).to receive(:say)
    end

    it "displays page type component mapping header" do
      generator.send(:check_page_type_components)

      expect(generator).to have_received(:say).with("Page Type Component Mapping:", :green)
    end

    it "displays components for each page type" do
      generator.send(:check_page_type_components)

      # Should have output for each page type
      expect(generator).to have_received(:say).at_least(4).times
    end
  end

  describe "#extract_local_components" do
    let(:generator) { described_class.new([], {}, destination_root: destination) }
    let(:test_file) { File.join(destination, "test_page.rb") }

    it "extracts component names from file content" do
      File.write(test_file, <<~RUBY)
        class TestPage < IndexBasePage
          register_component :sidebar
          register_component :custom_widget
        end
      RUBY

      components = generator.send(:extract_local_components, test_file)

      expect(components).to contain_exactly(:sidebar, :custom_widget)
    end

    it "returns empty array when no components found" do
      File.write(test_file, <<~RUBY)
        class TestPage < IndexBasePage
          def header
            { title: "Test" }
          end
        end
      RUBY

      components = generator.send(:extract_local_components, test_file)

      expect(components).to eq([])
    end

    it "handles multiple register_component calls on same line" do
      File.write(test_file, <<~RUBY)
        register_component :one
        register_component :two
        register_component :three
      RUBY

      components = generator.send(:extract_local_components, test_file)

      expect(components).to contain_exactly(:one, :two, :three)
    end
  end

  describe "component comparison" do
    let(:generator) { described_class.new([], {}, destination_root: destination) }

    before do
      allow(generator).to receive(:say)
      allow(generator).to receive(:check_page_type_components)
      allow(generator).to receive(:check_base_page_files)
    end

    context "when configuration is up to date" do
      it "displays up to date message" do
        # The default configuration should match DefaultComponents
        generator.check_components

        expect(generator).to have_received(:say).with("Your configuration is up to date!", :green)
      end
    end

    context "when there are new components in gem" do
      before do
        # Simulate gem having more components than user
        allow(BetterPage::DefaultComponents).to receive(:component_names).and_return(%i[header table new_component])
        allow(BetterPage.configuration).to receive(:component_names).and_return(%i[header table])
      end

      it "displays new components message" do
        generator.check_components

        expect(generator).to have_received(:say).with("New components available from gem:", :yellow)
      end
    end

    context "when user has custom components" do
      before do
        allow(BetterPage::DefaultComponents).to receive(:component_names).and_return(%i[header table])
        allow(BetterPage.configuration).to receive(:component_names).and_return(%i[header table custom_component])
      end

      it "displays custom components message" do
        generator.check_components

        expect(generator).to have_received(:say).with("Custom components in your configuration:", :cyan)
      end
    end
  end

  describe "#check_base_page_files" do
    let(:generator) { described_class.new([], {}, destination_root: destination) }

    before do
      allow(generator).to receive(:say)
    end

    it "displays header" do
      generator.send(:check_base_page_files)

      expect(generator).to have_received(:say).with("Local Base Page Files:", :green)
    end

    it "shows file status for existing files" do
      generator.send(:check_base_page_files)

      # rails_app has index_base_page.rb, show_base_page.rb, etc.
      expect(generator).to have_received(:say).at_least(:once)
    end

    it "shows NOT FOUND for missing base page files" do
      # Stub Rails.root to point to a directory without base page files
      allow(Rails).to receive(:root).and_return(Pathname.new(destination))

      generator.send(:check_base_page_files)

      # Should display NOT FOUND for missing files
      expect(generator).to have_received(:say).with(/NOT FOUND/, :red).at_least(:once)
      expect(generator).to have_received(:say).with(/Run: rails g better_page:install/, :yellow).at_least(:once)
    end

    it "shows files with custom components" do
      # Create a base page with custom components
      FileUtils.mkdir_p(File.join(destination, "app", "pages"))
      File.write(File.join(destination, "app", "pages", "index_base_page.rb"), <<~RUBY)
        class IndexBasePage < ApplicationPage
          register_component :custom_sidebar
          register_component :extra_widget
        end
      RUBY

      allow(Rails).to receive(:root).and_return(Pathname.new(destination))

      generator.send(:check_base_page_files)

      expect(generator).to have_received(:say).with(/index_base_page.rb:.*custom_sidebar/, :cyan)
    end

    it "shows files without custom components" do
      # Create a base page without custom components
      FileUtils.mkdir_p(File.join(destination, "app", "pages"))
      File.write(File.join(destination, "app", "pages", "index_base_page.rb"), <<~RUBY)
        class IndexBasePage < ApplicationPage
          # No custom components
        end
      RUBY

      allow(Rails).to receive(:root).and_return(Pathname.new(destination))

      generator.send(:check_base_page_files)

      expect(generator).to have_received(:say).with(/index_base_page.rb:.*no custom components/, :white)
    end
  end

  describe "#extract_local_components" do
    let(:generator) { described_class.new([], {}, destination_root: destination) }

    it "returns empty array for files without register_component" do
      file_path = File.join(destination, "empty.rb")
      File.write(file_path, "class Test\nend")

      result = generator.send(:extract_local_components, file_path)

      expect(result).to eq([])
    end

    it "extracts single component" do
      file_path = File.join(destination, "single.rb")
      File.write(file_path, "register_component :my_component")

      result = generator.send(:extract_local_components, file_path)

      expect(result).to eq([:my_component])
    end

    it "extracts multiple components" do
      file_path = File.join(destination, "multi.rb")
      File.write(file_path, <<~RUBY)
        register_component :first
        register_component :second
        register_component :third
      RUBY

      result = generator.send(:extract_local_components, file_path)

      expect(result).to contain_exactly(:first, :second, :third)
    end
  end
end
