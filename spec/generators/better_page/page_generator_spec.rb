# frozen_string_literal: true

require "rails_helper"
require "generators/better_page/page_generator"
require "fileutils"

RSpec.describe BetterPage::Generators::PageGenerator, type: :generator do
  let(:destination) { File.expand_path("../../../tmp/generator_test", __dir__) }

  before do
    FileUtils.rm_rf(destination)
    FileUtils.mkdir_p(destination)
    FileUtils.mkdir_p(File.join(destination, "app", "pages"))
  end

  after do
    FileUtils.rm_rf(destination)
  end

  describe "source_root" do
    it "points to templates directory" do
      expect(described_class.source_root).to include("templates")
    end
  end

  describe "arguments" do
    it "requires resource argument" do
      argument = described_class.arguments.find { |a| a.name == "resource" }
      expect(argument).not_to be_nil
      expect(argument.required).to be true
    end

    it "has optional actions argument" do
      argument = described_class.arguments.find { |a| a.name == "actions" }
      expect(argument).not_to be_nil
      expect(argument.default).to eq([])
    end
  end

  describe "#template_for_action" do
    let(:generator) { described_class.new([ "Products" ], [], destination_root: destination) }

    it "returns index_page for index action" do
      expect(generator.send(:template_for_action, "index")).to eq("index_page")
    end

    it "returns show_page for show action" do
      expect(generator.send(:template_for_action, "show")).to eq("show_page")
    end

    it "returns new_page for new action" do
      expect(generator.send(:template_for_action, "new")).to eq("new_page")
    end

    it "returns edit_page for edit action" do
      expect(generator.send(:template_for_action, "edit")).to eq("edit_page")
    end

    it "returns custom_page for custom action" do
      expect(generator.send(:template_for_action, "custom")).to eq("custom_page")
    end

    it "returns nil for unknown action" do
      expect(generator.send(:template_for_action, "unknown")).to be_nil
    end
  end

  describe "#page_path" do
    it "generates correct path for simple resource" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      path = generator.send(:page_path, "index")

      expect(path).to eq("app/pages/products/index_page.rb")
    end

    it "generates correct path for namespaced resource" do
      generator = described_class.new([ "Admin::Users" ], [], destination_root: destination)
      path = generator.send(:page_path, "index")

      expect(path).to eq("app/pages/admin/users/index_page.rb")
    end

    it "generates correct path for deeply namespaced resource" do
      generator = described_class.new([ "Admin::Settings::Roles" ], [], destination_root: destination)
      path = generator.send(:page_path, "show")

      expect(path).to eq("app/pages/admin/settings/roles/show_page.rb")
    end
  end

  describe "#namespace_path" do
    it "returns underscored path parts" do
      generator = described_class.new([ "Admin::Users" ], [], destination_root: destination)
      expect(generator.send(:namespace_path)).to eq(%w[admin users])
    end

    it "handles simple resources" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:namespace_path)).to eq(%w[products])
    end
  end

  describe "#resource_namespace" do
    it "returns namespace for namespaced resource" do
      generator = described_class.new([ "Admin::Users" ], [], destination_root: destination)
      expect(generator.send(:resource_namespace)).to eq("Admin")
    end

    it "returns nil for simple resource" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:resource_namespace)).to be_nil
    end

    it "returns nested namespace" do
      generator = described_class.new([ "Admin::Settings::Roles" ], [], destination_root: destination)
      expect(generator.send(:resource_namespace)).to eq("Admin::Settings")
    end
  end

  describe "#resource_name" do
    it "returns last part of namespaced resource" do
      generator = described_class.new([ "Admin::Users" ], [], destination_root: destination)
      expect(generator.send(:resource_name)).to eq("Users")
    end

    it "returns resource for simple resource" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:resource_name)).to eq("Products")
    end
  end

  describe "#resource_singular" do
    it "returns singular underscored name" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:resource_singular)).to eq("product")
    end

    it "handles already singular names" do
      generator = described_class.new([ "User" ], [], destination_root: destination)
      expect(generator.send(:resource_singular)).to eq("user")
    end
  end

  describe "#resource_plural" do
    it "returns plural underscored name" do
      generator = described_class.new([ "Product" ], [], destination_root: destination)
      expect(generator.send(:resource_plural)).to eq("products")
    end

    it "handles already plural names" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:resource_plural)).to eq("products")
    end
  end

  describe "#full_class_name" do
    it "generates full class name for simple resource" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:full_class_name, "index")).to eq("Products::IndexPage")
    end

    it "generates full class name for namespaced resource" do
      generator = described_class.new([ "Admin::Users" ], [], destination_root: destination)
      expect(generator.send(:full_class_name, "show")).to eq("Admin::Users::ShowPage")
    end
  end

  describe "#module_nesting_start" do
    it "generates module nesting for simple resource" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:module_nesting_start)).to eq("module Products")
    end

    it "generates nested modules for namespaced resource" do
      generator = described_class.new([ "Admin::Users" ], [], destination_root: destination)
      nesting = generator.send(:module_nesting_start)
      expect(nesting).to include("module Admin")
      expect(nesting).to include("module Users")
    end
  end

  describe "#class_indent" do
    it "returns correct indentation for simple resource" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:class_indent)).to eq("  ")
    end

    it "returns correct indentation for namespaced resource" do
      generator = described_class.new([ "Admin::Users" ], [], destination_root: destination)
      expect(generator.send(:class_indent)).to eq("    ")
    end
  end

  describe "templates existence" do
    it "has index_page template" do
      expect(File.exist?(File.join(described_class.source_root, "index_page.rb.tt"))).to be true
    end

    it "has show_page template" do
      expect(File.exist?(File.join(described_class.source_root, "show_page.rb.tt"))).to be true
    end

    it "has new_page template" do
      expect(File.exist?(File.join(described_class.source_root, "new_page.rb.tt"))).to be true
    end

    it "has edit_page template" do
      expect(File.exist?(File.join(described_class.source_root, "edit_page.rb.tt"))).to be true
    end

    it "has custom_page template" do
      expect(File.exist?(File.join(described_class.source_root, "custom_page.rb.tt"))).to be true
    end
  end

  describe "#module_nesting_end" do
    it "generates end statements for simple resource" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      expect(generator.send(:module_nesting_end)).to eq("end")
    end

    it "generates multiple end statements for namespaced resource" do
      generator = described_class.new([ "Admin::Users" ], [], destination_root: destination)
      nesting = generator.send(:module_nesting_end)
      expect(nesting).to eq("end\nend")
    end

    it "generates three end statements for deeply nested resource" do
      generator = described_class.new([ "Admin::Settings::Roles" ], [], destination_root: destination)
      nesting = generator.send(:module_nesting_end)
      expect(nesting).to eq("end\nend\nend")
    end
  end

  describe "#check_pages_directory" do
    it "allows generation when app/pages exists" do
      generator = described_class.new([ "Products" ], [], destination_root: destination)
      # Directory exists from before block - stub Rails.root to point to destination
      allow(Rails).to receive(:root).and_return(Pathname.new(destination))

      expect { generator.check_pages_directory }.not_to raise_error
    end

    it "exits when app/pages directory does not exist" do
      # Remove the pages directory
      FileUtils.rm_rf(File.join(destination, "app", "pages"))

      generator = described_class.new([ "Products" ], [], destination_root: destination)
      allow(generator).to receive(:say)
      # Stub Rails.root to point to destination where app/pages doesn't exist
      allow(Rails).to receive(:root).and_return(Pathname.new(destination))

      expect { generator.check_pages_directory }.to raise_error(SystemExit)
      expect(generator).to have_received(:say).with(/app\/pages directory not found/, :red)
    end
  end

  describe "#create_page_files" do
    context "with explicit actions" do
      let(:generator) { described_class.new([ "Products", "index" ], [], destination_root: destination) }

      before do
        allow(generator).to receive(:template)
      end

      it "generates specified action" do
        generator.create_page_files

        expect(generator).to have_received(:template).with(
          "index_page.rb.tt",
          "app/pages/products/index_page.rb"
        )
      end
    end

    context "with unknown action" do
      let(:generator) { described_class.new([ "Products", "unknown_action" ], [], destination_root: destination) }

      before do
        allow(generator).to receive(:template)
        allow(generator).to receive(:say)
      end

      it "skips unknown action and shows warning" do
        generator.create_page_files

        expect(generator).not_to have_received(:template)
        expect(generator).to have_received(:say).with(/Unknown action.*Skipping/, :yellow)
      end
    end

    context "with no actions specified" do
      let(:generator) { described_class.new([ "Products" ], [], destination_root: destination) }

      before do
        allow(generator).to receive(:template)
      end

      it "generates default actions (index, show, new, edit)" do
        generator.create_page_files

        expect(generator).to have_received(:template).with("index_page.rb.tt", anything)
        expect(generator).to have_received(:template).with("show_page.rb.tt", anything)
        expect(generator).to have_received(:template).with("new_page.rb.tt", anything)
        expect(generator).to have_received(:template).with("edit_page.rb.tt", anything)
      end
    end

    context "with custom action" do
      let(:generator) { described_class.new([ "Products", "custom" ], [], destination_root: destination) }

      before do
        allow(generator).to receive(:template)
      end

      it "generates custom_page template" do
        generator.create_page_files

        expect(generator).to have_received(:template).with(
          "custom_page.rb.tt",
          "app/pages/products/custom_page.rb"
        )
      end
    end
  end

  describe "#show_completion_message" do
    let(:generator) { described_class.new([ "Products" ], [], destination_root: destination) }

    before do
      allow(generator).to receive(:say)
    end

    it "displays success message" do
      generator.show_completion_message

      expect(generator).to have_received(:say).with("Pages generated successfully!", :green)
    end

    it "displays empty lines for formatting" do
      generator.show_completion_message

      expect(generator).to have_received(:say).with("").at_least(:twice)
    end
  end
end
