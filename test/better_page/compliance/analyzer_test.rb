# frozen_string_literal: true

require "test_helper"
require "tempfile"
require "fileutils"

class BetterPage::Compliance::AnalyzerTest < ActiveSupport::TestCase
  def setup
    @analyzer = BetterPage::Compliance::Analyzer.new
  end

  # Helper to create temporary page files for testing
  def with_temp_page(content, filename: "test_page.rb")
    Dir.mktmpdir do |dir|
      file_path = File.join(dir, filename)
      File.write(file_path, content)
      yield file_path
    end
  end

  test "initializes with zero counters" do
    assert_equal [], @analyzer.results
    assert_equal 0, @analyzer.total_pages
    assert_equal 0, @analyzer.compliant_count
    assert_equal 0, @analyzer.warning_count
    assert_equal 0, @analyzer.error_count
  end

  test "analyze_page extracts class name" do
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
      result = @analyzer.analyze_page(file_path)

      assert_equal "Admin::Users::IndexPage", result[:class_name]
    end
  end

  test "analyze_page detects index page type" do
    content = <<~RUBY
      class IndexPage < BetterPage::IndexBasePage
        def initialize(items); end
        def header; {}; end
        def table; {}; end
      end
    RUBY

    with_temp_page(content, filename: "index_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_equal :index_page, result[:page_type]
    end
  end

  test "analyze_page detects show page type" do
    content = <<~RUBY
      class ShowPage < BetterPage::ShowBasePage
        def initialize(item); end
        def header; {}; end
      end
    RUBY

    with_temp_page(content, filename: "show_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_equal :show_page, result[:page_type]
    end
  end

  test "analyze_page detects form page type for new" do
    content = <<~RUBY
      class NewPage < BetterPage::FormBasePage
        def initialize(item); end
        def header; {}; end
        def panels; []; end
      end
    RUBY

    with_temp_page(content, filename: "new_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_equal :form_page, result[:page_type]
    end
  end

  test "analyze_page detects form page type for edit" do
    content = <<~RUBY
      class EditPage < BetterPage::FormBasePage
        def initialize(item); end
        def header; {}; end
        def panels; []; end
      end
    RUBY

    with_temp_page(content, filename: "edit_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_equal :form_page, result[:page_type]
    end
  end

  test "analyze_page detects custom page type" do
    content = <<~RUBY
      class CustomPage < BetterPage::CustomBasePage
        def initialize(data); end
        def content; {}; end
      end
    RUBY

    with_temp_page(content, filename: "custom_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_equal :custom_page, result[:page_type]
    end
  end

  test "detects missing required header method for index page" do
    content = <<~RUBY
      class IndexPage < BetterPage::IndexBasePage
        def initialize(items); end
        def table; {}; end
      end
    RUBY

    with_temp_page(content, filename: "index_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "Missing required component method: header"
    end
  end

  test "detects missing required table method for index page" do
    content = <<~RUBY
      class IndexPage < BetterPage::IndexBasePage
        def initialize(items); end
        def header; {}; end
      end
    RUBY

    with_temp_page(content, filename: "index_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "Missing required component method: table"
    end
  end

  test "detects missing required panels method for form page" do
    content = <<~RUBY
      class NewPage < BetterPage::FormBasePage
        def initialize(item); end
        def header; {}; end
      end
    RUBY

    with_temp_page(content, filename: "new_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "Missing required component method: panels"
    end
  end

  test "detects missing required content method for custom page" do
    content = <<~RUBY
      class CustomPage < BetterPage::CustomBasePage
        def initialize(data); end
        def header; {}; end
      end
    RUBY

    with_temp_page(content, filename: "custom_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "Missing required component method: content"
    end
  end

  test "detects database query with find" do
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
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "Database queries forbidden in Page"
    end
  end

  test "detects database query with where" do
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
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "Database queries forbidden in Page"
    end
  end

  test "detects service layer access" do
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
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "Service layer access forbidden in Page"
    end
  end

  test "detects business logic methods" do
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
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "Business calculations forbidden in Page"
    end
  end

  test "detects OpenStruct usage" do
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
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:issues], "OpenStruct usage forbidden - use plain Hash objects"
    end
  end

  test "warns about Struct usage" do
    content = <<~RUBY
      class IndexPage < BetterPage::IndexBasePage
        HeaderData = Struct.new(:title)
        def initialize; end
        def header; {}; end
        def table; {}; end
      end
    RUBY

    with_temp_page(content, filename: "index_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:warnings], "Struct usage discouraged - prefer plain Hash for consistency"
    end
  end

  test "warns about hardcoded paths" do
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
      result = @analyzer.analyze_page(file_path)

      assert_includes result[:warnings], "Hardcoded paths detected - prefer Rails path helpers"
    end
  end

  test "compliant page returns compliant status" do
    # Note: Using symbol keys and Rails path helpers to avoid warnings
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
      result = @analyzer.analyze_page(file_path)

      assert result[:compliant]
      # May have warnings (like missing main method warning) but no errors
      assert_includes [:compliant, :warning], result[:status]
      assert_empty result[:issues]
    end
  end

  test "page with issues returns error status" do
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
      result = @analyzer.analyze_page(file_path)

      refute result[:compliant]
      assert_equal :error, result[:status]
    end
  end

  test "page with only warnings returns warning status" do
    content = <<~RUBY
      class IndexPage < BetterPage::IndexBasePage
        HeaderData = Struct.new(:title)
        def initialize; end
        def header; {}; end
        def table; {}; end
      end
    RUBY

    with_temp_page(content, filename: "index_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      assert result[:compliant]
      assert_equal :warning, result[:status]
    end
  end

  test "format_single_page_report shows OK for compliant" do
    result = {
      file_path: "app/pages/test_page.rb",
      class_name: "TestPage",
      page_type: :index_page,
      namespace: "Admin",
      issues: [],
      warnings: [],
      status: :compliant
    }

    output = @analyzer.format_single_page_report(result)

    assert_includes output, "[OK]"
    assert_includes output, "app/pages/test_page.rb"
  end

  test "format_single_page_report shows ERROR for issues" do
    result = {
      file_path: "app/pages/test_page.rb",
      class_name: "TestPage",
      page_type: :index_page,
      namespace: "Admin",
      issues: ["Database queries forbidden"],
      warnings: [],
      status: :error
    }

    output = @analyzer.format_single_page_report(result)

    assert_includes output, "[ERROR]"
    assert_includes output, "Database queries forbidden"
  end

  test "format_single_page_report shows WARN for warnings" do
    result = {
      file_path: "app/pages/test_page.rb",
      class_name: "TestPage",
      page_type: :index_page,
      namespace: "Admin",
      issues: [],
      warnings: ["Hardcoded paths detected"],
      status: :warning
    }

    output = @analyzer.format_single_page_report(result)

    assert_includes output, "[WARN]"
    assert_includes output, "Hardcoded paths detected"
  end

  test "handles files without class definition" do
    content = "# just a comment, no class"

    with_temp_page(content, filename: "broken_page.rb") do |file_path|
      result = @analyzer.analyze_page(file_path)

      # When no class is found, class_name is UNKNOWN
      assert_equal "UNKNOWN", result[:class_name]
      # The page should have issues because it doesn't end with Page
      assert result[:issues].any?
      refute result[:compliant]
    end
  end
end
