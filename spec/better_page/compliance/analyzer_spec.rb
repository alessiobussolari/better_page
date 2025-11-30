# frozen_string_literal: true

require "rails_helper"
require "tempfile"
require "fileutils"

RSpec.describe BetterPage::Compliance::Analyzer do
  let(:analyzer) { described_class.new }

  # Helper to create temporary page files for testing
  def with_temp_page(content, filename: "test_page.rb")
    Dir.mktmpdir do |dir|
      file_path = File.join(dir, filename)
      File.write(file_path, content)
      yield file_path
    end
  end

  describe "initialization" do
    it "initializes with zero counters" do
      expect(analyzer.results).to eq([])
      expect(analyzer.total_pages).to eq(0)
      expect(analyzer.compliant_count).to eq(0)
      expect(analyzer.warning_count).to eq(0)
      expect(analyzer.error_count).to eq(0)
    end
  end

  describe "#analyze_page" do
    it "extracts class name" do
      content = <<~RUBY
        class Admin::Users::IndexPage < BetterPage::IndexBasePage
          def initialize(users)
            @users = users
          end

          def header
            { title: "Users" }
          end

          def table
            { items: @users }
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:class_name]).to eq("Admin::Users::IndexPage")
      end
    end

    it "detects index page type" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize(items); end
          def header; {}; end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:index_page)
      end
    end

    it "detects show page type" do
      content = <<~RUBY
        class ShowPage < BetterPage::ShowBasePage
          def initialize(item); end
          def header; {}; end
        end
      RUBY

      with_temp_page(content, filename: "show_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:show_page)
      end
    end

    it "detects form page type for new" do
      content = <<~RUBY
        class NewPage < BetterPage::FormBasePage
          def initialize(item); end
          def header; {}; end
          def panels; []; end
        end
      RUBY

      with_temp_page(content, filename: "new_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:form_page)
      end
    end

    it "detects form page type for edit" do
      content = <<~RUBY
        class EditPage < BetterPage::FormBasePage
          def initialize(item); end
          def header; {}; end
          def panels; []; end
        end
      RUBY

      with_temp_page(content, filename: "edit_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:form_page)
      end
    end

    it "detects custom page type" do
      content = <<~RUBY
        class CustomPage < BetterPage::CustomBasePage
          def initialize(data); end
          def content; {}; end
        end
      RUBY

      with_temp_page(content, filename: "custom_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:custom_page)
      end
    end
  end

  describe "missing required methods detection" do
    it "detects missing required header method for index page" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize(items); end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Missing required component method: header")
      end
    end

    it "detects missing required table method for index page" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize(items); end
          def header; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Missing required component method: table")
      end
    end

    it "detects missing required panels method for form page" do
      content = <<~RUBY
        class NewPage < BetterPage::FormBasePage
          def initialize(item); end
          def header; {}; end
        end
      RUBY

      with_temp_page(content, filename: "new_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Missing required component method: panels")
      end
    end

    it "detects missing required content method for custom page" do
      content = <<~RUBY
        class CustomPage < BetterPage::CustomBasePage
          def initialize(data); end
          def header; {}; end
        end
      RUBY

      with_temp_page(content, filename: "custom_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Missing required component method: content")
      end
    end
  end

  describe "database query detection" do
    it "detects database query with find" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            { items: User.find(1) }
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Database queries forbidden in Page")
      end
    end

    it "detects database query with where" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            { items: User.where(active: true) }
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Database queries forbidden in Page")
      end
    end
  end

  describe "service layer detection" do
    it "detects service layer access" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            data = UserService.new.call
            { items: data }
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Service layer access forbidden in Page")
      end
    end
  end

  describe "business logic detection" do
    it "detects business logic methods" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table; {}; end

          def calculate_totals
            # business logic
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Business calculations forbidden in Page")
      end
    end
  end

  describe "structure usage detection" do
    it "detects OpenStruct usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header
            OpenStruct.new(title: "Test")
          end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("OpenStruct usage forbidden - use plain Hash objects")
      end
    end

    it "warns about Struct usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          HeaderData = Struct.new(:title)
          def initialize; end
          def header; {}; end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:warnings]).to include("Struct usage discouraged - prefer plain Hash for consistency")
      end
    end
  end

  describe "hardcoded paths detection" do
    it "warns about hardcoded paths" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header
            { title: "Test", path: "/users/new" }
          end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:warnings]).to include("Hardcoded paths detected - prefer Rails path helpers")
      end
    end
  end

  describe "compliance status" do
    it "compliant page returns compliant status" do
      content = <<~RUBY
        class Admin::Users::IndexPage < BetterPage::IndexBasePage
          def initialize(users)
            @users = users
          end

          def header
            { title: title_text, breadcrumbs: breadcrumb_items, actions: action_items }
          end

          def table
            { items: @users, columns: column_config, empty_state: empty_config }
          end

          private

          def title_text
            "Users"
          end

          def breadcrumb_items
            []
          end

          def action_items
            []
          end

          def column_config
            []
          end

          def empty_config
            {}
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)

        expect(result[:compliant]).to be true
        expect([:compliant, :warning]).to include(result[:status])
        expect(result[:issues]).to be_empty
      end
    end

    it "page with issues returns error status" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            { items: User.all }
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)

        expect(result[:compliant]).to be false
        expect(result[:status]).to eq(:error)
      end
    end

    it "page with only warnings returns warning status" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          HeaderData = Struct.new(:title)
          def initialize; end
          def header; {}; end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)

        expect(result[:compliant]).to be true
        expect(result[:status]).to eq(:warning)
      end
    end
  end

  describe "#format_single_page_report" do
    it "shows OK for compliant" do
      result = {
        file_path: "app/pages/test_page.rb",
        class_name: "TestPage",
        page_type: :index_page,
        namespace: "Admin",
        issues: [],
        warnings: [],
        status: :compliant
      }

      output = analyzer.format_single_page_report(result)

      expect(output).to include("[OK]")
      expect(output).to include("app/pages/test_page.rb")
    end

    it "shows ERROR for issues" do
      result = {
        file_path: "app/pages/test_page.rb",
        class_name: "TestPage",
        page_type: :index_page,
        namespace: "Admin",
        issues: ["Database queries forbidden"],
        warnings: [],
        status: :error
      }

      output = analyzer.format_single_page_report(result)

      expect(output).to include("[ERROR]")
      expect(output).to include("Database queries forbidden")
    end

    it "shows WARN for warnings" do
      result = {
        file_path: "app/pages/test_page.rb",
        class_name: "TestPage",
        page_type: :index_page,
        namespace: "Admin",
        issues: [],
        warnings: ["Hardcoded paths detected"],
        status: :warning
      }

      output = analyzer.format_single_page_report(result)

      expect(output).to include("[WARN]")
      expect(output).to include("Hardcoded paths detected")
    end
  end

  describe "edge cases" do
    it "handles files without class definition" do
      content = "# just a comment, no class"

      with_temp_page(content, filename: "broken_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)

        expect(result[:class_name]).to eq("UNKNOWN")
        expect(result[:issues]).not_to be_empty
        expect(result[:compliant]).to be false
      end
    end
  end
end
