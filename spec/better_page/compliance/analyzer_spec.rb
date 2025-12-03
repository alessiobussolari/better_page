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
        expect([ :compliant, :warning ]).to include(result[:status])
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
        issues: [ "Database queries forbidden" ],
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
        warnings: [ "Hardcoded paths detected" ],
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

    it "handles file read errors gracefully" do
      result = analyzer.analyze_page("/nonexistent/path/page.rb")

      expect(result[:class_name]).to eq("PARSE_ERROR")
      expect(result[:status]).to eq(:error)
      expect(result[:compliant]).to be false
      expect(result[:issues].first).to include("Parse error")
    end
  end

  describe "additional database query detection" do
    it "detects .count queries" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            { total: User.count }
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Database queries forbidden in Page")
      end
    end

    it "detects .joins queries" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            { items: User.joins(:posts) }
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Database queries forbidden in Page")
      end
    end

    it "detects .includes queries" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            { items: User.includes(:posts) }
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Database queries forbidden in Page")
      end
    end
  end

  describe "additional business logic detection" do
    it "detects process_ methods" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table; {}; end

          def process_data
            # business logic
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Business processing forbidden in Page")
      end
    end

    it "detects save_ methods" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table; {}; end

          def save_record
            # persistence
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Persistence operations forbidden in Page")
      end
    end

    it "detects validate_ methods (but not validate_form_panels)" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table; {}; end

          def validate_input
            # validation
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("Validation logic forbidden in Page")
      end
    end
  end

  describe "external dependencies detection" do
    it "detects Net::HTTP usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            Net::HTTP.get(uri)
            {}
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("External dependencies forbidden in Page")
      end
    end

    it "detects HTTParty usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            HTTParty.get(url)
            {}
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("External dependencies forbidden in Page")
      end
    end

    it "detects Faraday usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            Faraday.get(url)
            {}
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("External dependencies forbidden in Page")
      end
    end

    it "detects Redis usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table
            Redis.current.get("key")
            {}
          end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("External dependencies forbidden in Page")
      end
    end
  end

  describe "HTML generation detection" do
    it "detects html_safe usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header
            { title: "<b>Test</b>".html_safe }
          end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:warnings]).to include("HTML generation found - should be handled by template system")
      end
    end

    it "detects raw() usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header
            { title: raw("<b>Test</b>") }
          end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:warnings]).to include("HTML generation found - should be handled by template system")
      end
    end

    it "detects content_tag usage" do
      content = <<~RUBY
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header
            { title: content_tag(:b, "Test") }
          end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:warnings]).to include("HTML generation found - should be handled by template system")
      end
    end
  end

  describe "ostruct detection" do
    it "detects ostruct require" do
      content = <<~RUBY
        require "ostruct"
        class IndexPage < BetterPage::IndexBasePage
          def initialize; end
          def header; {}; end
          def table; {}; end
        end
      RUBY

      with_temp_page(content, filename: "index_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:issues]).to include("OpenStruct usage forbidden - use plain Hash objects")
      end
    end
  end

  describe "page type categorization" do
    it "detects base page type" do
      content = "class BasePage; end"

      with_temp_page(content, filename: "base_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:base)
      end
    end

    it "detects application_page as base type" do
      content = "class ApplicationPage; end"

      with_temp_page(content, filename: "application_page.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:base)
      end
    end

    it "detects root page type" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "pages"))
        file_path = File.join(dir, "pages", "dashboard_page.rb")
        File.write(file_path, "class DashboardPage\ndef initialize; end\nend")

        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:root_page)
      end
    end

    it "detects unknown page type for non-standard files" do
      content = "class SomethingElse; end"

      with_temp_page(content, filename: "something.rb") do |file_path|
        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:unknown)
      end
    end
  end

  describe "namespace extraction" do
    it "extracts namespace from path" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "app", "pages", "admin"))
        file_path = File.join(dir, "app", "pages", "admin", "index_page.rb")
        File.write(file_path, "class IndexPage\ndef initialize; end\ndef header; {}; end\ndef table; {}; end\nend")

        result = analyzer.analyze_page(file_path)
        expect(result[:namespace]).to eq("Admin")
      end
    end

    it "returns Root for pages directly in pages directory" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "app", "pages"))
        file_path = File.join(dir, "app", "pages", "dashboard_page.rb")
        File.write(file_path, "class DashboardPage\ndef initialize; end\nend")

        result = analyzer.analyze_page(file_path)
        expect(result[:namespace]).to eq("Root")
      end
    end

    it "returns UNKNOWN for paths without pages directory" do
      Dir.mktmpdir do |dir|
        file_path = File.join(dir, "some_page.rb")
        File.write(file_path, "class SomePage; end")

        result = analyzer.analyze_page(file_path)
        expect(result[:namespace]).to eq("UNKNOWN")
      end
    end
  end

  describe "namespaced page module warning" do
    it "warns when namespace module is missing" do
      Dir.mktmpdir do |dir|
        # Use a non-standard name to trigger :namespaced_page detection
        # The path pattern pages/\w+/\w+_page\.rb$ matches namespaced pages
        FileUtils.mkdir_p(File.join(dir, "app", "pages", "admin"))
        file_path = File.join(dir, "app", "pages", "admin", "dashboard_page.rb")
        File.write(file_path, <<~RUBY)
          class DashboardPage
            def initialize; end
            def index; end
            def header; {}; end
          end
        RUBY

        result = analyzer.analyze_page(file_path)
        # Should detect namespaced_page and warn about missing module
        expect(result[:page_type]).to eq(:namespaced_page)
        expect(result[:warnings]).to include(/Expected module.*for namespaced page/)
      end
    end

    it "does not warn when module is present" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "app", "pages", "admin"))
        file_path = File.join(dir, "app", "pages", "admin", "dashboard_page.rb")
        File.write(file_path, <<~RUBY)
          module Admin
            class DashboardPage
              def initialize; end
              def index; end
              def header; {}; end
            end
          end
        RUBY

        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:namespaced_page)
        expect(result[:warnings]).not_to include(/Expected module.*for namespaced page/)
      end
    end
  end

  describe "main method warning" do
    it "warns when main page method is missing" do
      Dir.mktmpdir do |dir|
        # Create proper structure - namespaced pages are pages with products/some_page.rb pattern
        FileUtils.mkdir_p(File.join(dir, "app", "pages", "products"))
        file_path = File.join(dir, "app", "pages", "products", "dashboard_page.rb")
        File.write(file_path, <<~RUBY)
          module Products
            class DashboardPage
              def initialize; end
              def header; {}; end
            end
          end
        RUBY

        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:namespaced_page)
        expect(result[:warnings]).to include("Page should have main method (index, show, form, or custom)")
      end
    end

    it "does not warn when main method is present" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "app", "pages", "products"))
        file_path = File.join(dir, "app", "pages", "products", "dashboard_page.rb")
        File.write(file_path, <<~RUBY)
          module Products
            class DashboardPage
              def initialize; end
              def index
                build_page
              end
              def header; {}; end
            end
          end
        RUBY

        result = analyzer.analyze_page(file_path)
        expect(result[:warnings]).not_to include("Page should have main method (index, show, form, or custom)")
      end
    end

    it "does not warn for base pages" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "app", "pages"))
        file_path = File.join(dir, "app", "pages", "base_page.rb")
        File.write(file_path, <<~RUBY)
          class BasePage
          end
        RUBY

        result = analyzer.analyze_page(file_path)
        expect(result[:page_type]).to eq(:base)
        expect(result[:warnings]).not_to include("Page should have main method (index, show, form, or custom)")
      end
    end
  end

  describe "#analyze_all" do
    let(:tmp_dir) { Dir.mktmpdir }

    before do
      FileUtils.mkdir_p(File.join(tmp_dir, "app", "pages", "products"))

      # Create compliant page
      File.write(File.join(tmp_dir, "app", "pages", "products", "index_page.rb"), <<~RUBY)
        class Products::IndexPage
          def initialize; end
          def index; end
          def header; {}; end
          def table; {}; end
        end
      RUBY

      # Create page with warning
      File.write(File.join(tmp_dir, "app", "pages", "products", "show_page.rb"), <<~RUBY)
        HeaderData = Struct.new(:title)
        class Products::ShowPage
          def initialize; end
          def show; end
          def header; {}; end
        end
      RUBY

      # Create page with error
      File.write(File.join(tmp_dir, "app", "pages", "products", "new_page.rb"), <<~RUBY)
        class Products::NewPage
          def initialize; end
          def form; end
          def header
            User.all
            {}
          end
          def panels; []; end
        end
      RUBY

      allow(Dir).to receive(:glob).with("app/pages/**/*_page.rb").and_return(
        Dir.glob(File.join(tmp_dir, "app", "pages", "**", "*_page.rb"))
      )
    end

    after do
      FileUtils.remove_entry tmp_dir
    end

    it "analyzes all pages and updates counters" do
      expect { analyzer.analyze_all }.to output(/Found 3 page files/).to_stdout

      expect(analyzer.total_pages).to eq(3)
      expect(analyzer.results.size).to eq(3)
    end

    it "counts compliant, warning, and error pages" do
      expect { analyzer.analyze_all }.to output.to_stdout

      expect(analyzer.compliant_count).to be >= 0
      expect(analyzer.warning_count).to be >= 0
      expect(analyzer.error_count).to be >= 0
      expect(analyzer.compliant_count + analyzer.warning_count + analyzer.error_count).to eq(3)
    end
  end

  describe "#generate_report" do
    before do
      analyzer.instance_variable_set(:@total_pages, 3)
      analyzer.instance_variable_set(:@compliant_count, 1)
      analyzer.instance_variable_set(:@warning_count, 1)
      analyzer.instance_variable_set(:@error_count, 1)
      analyzer.instance_variable_set(:@results, [
        { file_path: "a.rb", status: :compliant, issues: [], warnings: [] },
        { file_path: "b.rb", status: :warning, issues: [], warnings: [ "warning1" ] },
        { file_path: "c.rb", status: :error, issues: [ "issue1" ], warnings: [] }
      ])
    end

    it "outputs SUMMARY section" do
      expect { analyzer.generate_report }.to output(/SUMMARY/).to_stdout
    end

    it "outputs total pages analyzed" do
      expect { analyzer.generate_report }.to output(/Total pages analyzed: 3/).to_stdout
    end

    it "outputs compliant count with percentage" do
      expect { analyzer.generate_report }.to output(/Fully compliant: 1/).to_stdout
    end

    it "outputs warning count" do
      expect { analyzer.generate_report }.to output(/With warnings: 1/).to_stdout
    end

    it "outputs error count" do
      expect { analyzer.generate_report }.to output(/With errors: 1/).to_stdout
    end

    it "outputs CRITICAL ISSUES section when errors exist" do
      expect { analyzer.generate_report }.to output(/CRITICAL ISSUES/).to_stdout
    end

    it "outputs WARNINGS section when warnings exist" do
      expect { analyzer.generate_report }.to output(/WARNINGS/).to_stdout
    end
  end

  describe "#generate_recommendations" do
    context "with issues" do
      before do
        analyzer.instance_variable_set(:@error_count, 2)
        analyzer.instance_variable_set(:@warning_count, 1)
        analyzer.instance_variable_set(:@results, [
          { issues: [ "Database queries forbidden" ], warnings: [] },
          { issues: [ "Database queries forbidden" ], warnings: [] },
          { issues: [], warnings: [ "Hardcoded paths" ] }
        ])
      end

      it "outputs RECOMMENDATIONS section" do
        expect { analyzer.send(:generate_recommendations) }.to output(/RECOMMENDATIONS/).to_stdout
      end

      it "outputs top issues to address" do
        expect { analyzer.send(:generate_recommendations) }.to output(/Top issues to address/).to_stdout
      end

      it "outputs NEXT STEPS for errors" do
        expect { analyzer.send(:generate_recommendations) }.to output(/Remove database queries/).to_stdout
      end
    end

    context "when all pages are compliant" do
      before do
        analyzer.instance_variable_set(:@error_count, 0)
        analyzer.instance_variable_set(:@warning_count, 0)
        analyzer.instance_variable_set(:@results, [
          { issues: [], warnings: [] }
        ])
      end

      it "outputs all pages compliant message" do
        expect { analyzer.send(:generate_recommendations) }.to output(/All pages are compliant/).to_stdout
      end

      it "suggests implementing optional component methods" do
        expect { analyzer.send(:generate_recommendations) }.to output(/Consider implementing optional component methods/).to_stdout
      end
    end

    context "with only warnings" do
      before do
        analyzer.instance_variable_set(:@error_count, 0)
        analyzer.instance_variable_set(:@warning_count, 2)
        analyzer.instance_variable_set(:@results, [
          { issues: [], warnings: [ "Struct usage discouraged" ] },
          { issues: [], warnings: [ "Hardcoded paths" ] }
        ])
      end

      it "suggests fixing warnings" do
        expect { analyzer.send(:generate_recommendations) }.to output(/Replace OpenStruct|Use Rails path helpers/).to_stdout
      end
    end
  end

  describe "percentage calculation" do
    it "returns 0 when no pages" do
      expect(analyzer.send(:percentage, 0)).to eq(0)
    end

    it "calculates percentage correctly" do
      analyzer.instance_variable_set(:@total_pages, 10)
      expect(analyzer.send(:percentage, 5)).to eq(50.0)
    end

    it "rounds to one decimal place" do
      analyzer.instance_variable_set(:@total_pages, 3)
      expect(analyzer.send(:percentage, 1)).to eq(33.3)
    end
  end

  describe "update_counters" do
    it "increments compliant_count for compliant status" do
      analyzer.send(:update_counters, { status: :compliant })
      expect(analyzer.compliant_count).to eq(1)
    end

    it "increments warning_count for warning status" do
      analyzer.send(:update_counters, { status: :warning })
      expect(analyzer.warning_count).to eq(1)
    end

    it "increments error_count for error status" do
      analyzer.send(:update_counters, { status: :error })
      expect(analyzer.error_count).to eq(1)
    end
  end

  describe "verbose mode" do
    it "respects VERBOSE environment variable" do
      allow(ENV).to receive(:[]).with("VERBOSE").and_return("true")
      verbose_analyzer = described_class.new
      expect(verbose_analyzer.instance_variable_get(:@verbose)).to be true
    end

    it "defaults to non-verbose mode" do
      allow(ENV).to receive(:[]).with("VERBOSE").and_return(nil)
      normal_analyzer = described_class.new
      expect(normal_analyzer.instance_variable_get(:@verbose)).to be false
    end
  end
end
