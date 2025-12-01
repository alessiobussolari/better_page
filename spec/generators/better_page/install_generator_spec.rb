# frozen_string_literal: true

require "rails_helper"
require "generators/better_page/install_generator"
require "fileutils"

RSpec.describe BetterPage::Generators::InstallGenerator, type: :generator do
  let(:destination) { File.expand_path("../../../tmp/generator_test", __dir__) }

  before do
    FileUtils.rm_rf(destination)
    FileUtils.mkdir_p(destination)
    FileUtils.mkdir_p(File.join(destination, "config", "initializers"))
    FileUtils.mkdir_p(File.join(destination, "app"))
  end

  after do
    FileUtils.rm_rf(destination)
  end

  describe "source_root" do
    it "points to templates directory" do
      expect(described_class.source_root).to include("templates")
    end
  end

  describe "#create_pages_directory" do
    it "creates app/pages directory" do
      generator = described_class.new([], {}, destination_root: destination)
      generator.create_pages_directory

      expect(File.directory?(File.join(destination, "app", "pages"))).to be true
    end
  end

  describe "#create_initializer" do
    it "creates better_page.rb initializer" do
      generator = described_class.new([], {}, destination_root: destination)

      # Stub template method
      allow(generator).to receive(:template)
      generator.create_initializer

      expect(generator).to have_received(:template).with(
        "better_page_initializer.rb.tt",
        "config/initializers/better_page.rb"
      )
    end
  end

  describe "#create_application_page" do
    it "creates application_page.rb" do
      generator = described_class.new([], {}, destination_root: destination)

      allow(generator).to receive(:template)
      generator.create_application_page

      expect(generator).to have_received(:template).with(
        "application_page.rb.tt",
        "app/pages/application_page.rb"
      )
    end
  end

  describe "#create_base_pages" do
    it "creates all base page files" do
      generator = described_class.new([], {}, destination_root: destination)

      allow(generator).to receive(:template)
      generator.create_base_pages

      expect(generator).to have_received(:template).with("index_base_page.rb.tt", "app/pages/index_base_page.rb")
      expect(generator).to have_received(:template).with("show_base_page.rb.tt", "app/pages/show_base_page.rb")
      expect(generator).to have_received(:template).with("form_base_page.rb.tt", "app/pages/form_base_page.rb")
      expect(generator).to have_received(:template).with("custom_base_page.rb.tt", "app/pages/custom_base_page.rb")
    end
  end

  describe "#create_view_components" do
    context "without skip_components option" do
      it "creates component directories" do
        generator = described_class.new([], {}, destination_root: destination)

        allow(generator).to receive(:empty_directory)
        allow(generator).to receive(:template)
        allow(generator).to receive(:copy_file)
        generator.create_view_components

        expect(generator).to have_received(:empty_directory).with("app/components/better_page")
        expect(generator).to have_received(:empty_directory).with("app/components/better_page/ui")
      end

      it "copies view components" do
        generator = described_class.new([], {}, destination_root: destination)

        allow(generator).to receive(:empty_directory)
        allow(generator).to receive(:template)
        allow(generator).to receive(:copy_file)
        generator.create_view_components

        # Main view components
        expect(generator).to have_received(:template).with("view_components/index_view_component.rb.tt", "app/components/better_page/index_view_component.rb")
        expect(generator).to have_received(:template).with("view_components/show_view_component.rb.tt", "app/components/better_page/show_view_component.rb")
        expect(generator).to have_received(:template).with("view_components/form_view_component.rb.tt", "app/components/better_page/form_view_component.rb")
        expect(generator).to have_received(:template).with("view_components/custom_view_component.rb.tt", "app/components/better_page/custom_view_component.rb")
      end

      it "copies UI components" do
        generator = described_class.new([], {}, destination_root: destination)

        allow(generator).to receive(:empty_directory)
        allow(generator).to receive(:template)
        allow(generator).to receive(:copy_file)
        generator.create_view_components

        # UI components
        expect(generator).to have_received(:template).with("view_components/ui/header_component.rb.tt", "app/components/better_page/ui/header_component.rb")
        expect(generator).to have_received(:template).with("view_components/ui/table_component.rb.tt", "app/components/better_page/ui/table_component.rb")
      end
    end

    context "with skip_components option" do
      it "skips component creation" do
        generator = described_class.new([], { skip_components: true }, destination_root: destination)

        allow(generator).to receive(:empty_directory)
        generator.create_view_components

        expect(generator).not_to have_received(:empty_directory)
      end
    end
  end

  describe "#create_stimulus_controllers" do
    context "without skip_components option" do
      it "creates stimulus controller directory" do
        generator = described_class.new([], {}, destination_root: destination)

        allow(generator).to receive(:empty_directory)
        allow(generator).to receive(:copy_file)
        allow(generator).to receive(:append_to_file)
        generator.create_stimulus_controllers

        expect(generator).to have_received(:empty_directory).with("app/javascript/controllers/better_page")
      end

      it "copies stimulus controllers" do
        generator = described_class.new([], {}, destination_root: destination)

        allow(generator).to receive(:empty_directory)
        allow(generator).to receive(:copy_file)
        allow(generator).to receive(:append_to_file)
        generator.create_stimulus_controllers

        expect(generator).to have_received(:copy_file).with(
          "javascript/controllers/dropdown_controller.js",
          "app/javascript/controllers/better_page/dropdown_controller.js"
        )
        expect(generator).to have_received(:copy_file).with(
          "javascript/controllers/index.js",
          "app/javascript/controllers/better_page/index.js"
        )
      end
    end

    context "with skip_components option" do
      it "skips stimulus controller creation" do
        generator = described_class.new([], { skip_components: true }, destination_root: destination)

        allow(generator).to receive(:empty_directory)
        generator.create_stimulus_controllers

        expect(generator).not_to have_received(:empty_directory)
      end
    end
  end

  describe "#show_post_install_message" do
    it "displays success message" do
      generator = described_class.new([], {}, destination_root: destination)

      allow(generator).to receive(:say)
      generator.show_post_install_message

      expect(generator).to have_received(:say).with("BetterPage has been installed successfully!", :green)
    end

    it "displays created files list" do
      generator = described_class.new([], {}, destination_root: destination)

      allow(generator).to receive(:say)
      generator.show_post_install_message

      expect(generator).to have_received(:say).with("  - config/initializers/better_page.rb (component configuration)")
      expect(generator).to have_received(:say).with("  - app/pages/application_page.rb")
    end

    it "displays component info when not skipped" do
      generator = described_class.new([], {}, destination_root: destination)

      allow(generator).to receive(:say)
      generator.show_post_install_message

      expect(generator).to have_received(:say).with("  - app/components/better_page/ (ViewComponents)")
    end

    it "skips component info when skipped" do
      generator = described_class.new([], { skip_components: true }, destination_root: destination)

      allow(generator).to receive(:say)
      generator.show_post_install_message

      expect(generator).not_to have_received(:say).with("  - app/components/better_page/ (ViewComponents)")
    end
  end

  describe "private methods" do
    describe "#copy_view_component" do
      it "templates both rb and erb files" do
        generator = described_class.new([], {}, destination_root: destination)

        allow(generator).to receive(:template)
        generator.send(:copy_view_component, "test_component")

        expect(generator).to have_received(:template).with("view_components/test_component.rb.tt", "app/components/better_page/test_component.rb")
        expect(generator).to have_received(:template).with("view_components/test_component.html.erb.tt", "app/components/better_page/test_component.html.erb")
      end
    end

    describe "#copy_ui_component" do
      it "templates UI component files" do
        generator = described_class.new([], {}, destination_root: destination)

        allow(generator).to receive(:template)
        generator.send(:copy_ui_component, "test")

        expect(generator).to have_received(:template).with("view_components/ui/test_component.rb.tt", "app/components/better_page/ui/test_component.rb")
        expect(generator).to have_received(:template).with("view_components/ui/test_component.html.erb.tt", "app/components/better_page/ui/test_component.html.erb")
      end
    end
  end

  describe "#ui_components" do
    it "returns list of UI component names" do
      generator = described_class.new([], {}, destination_root: destination)
      components = generator.send(:ui_components)

      expect(components).to include("header")
      expect(components).to include("table")
      expect(components).to include("alerts")
      expect(components).to include("pagination")
      expect(components).to include("panel")
      expect(components).to include("field")
    end
  end

  describe "class options" do
    it "has skip_components option" do
      option = described_class.class_options[:skip_components]

      expect(option).not_to be_nil
      expect(option.type).to eq(:boolean)
      expect(option.default).to be false
    end
  end

  describe "templates existence" do
    it "has application_page template" do
      expect(File.exist?(File.join(described_class.source_root, "application_page.rb.tt"))).to be true
    end

    it "has index_base_page template" do
      expect(File.exist?(File.join(described_class.source_root, "index_base_page.rb.tt"))).to be true
    end

    it "has show_base_page template" do
      expect(File.exist?(File.join(described_class.source_root, "show_base_page.rb.tt"))).to be true
    end

    it "has form_base_page template" do
      expect(File.exist?(File.join(described_class.source_root, "form_base_page.rb.tt"))).to be true
    end

    it "has custom_base_page template" do
      expect(File.exist?(File.join(described_class.source_root, "custom_base_page.rb.tt"))).to be true
    end

    it "has initializer template" do
      expect(File.exist?(File.join(described_class.source_root, "better_page_initializer.rb.tt"))).to be true
    end
  end
end
