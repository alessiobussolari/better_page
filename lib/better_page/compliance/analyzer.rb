# frozen_string_literal: true

module BetterPage
  module Compliance
    # Analyzer for page compliance with architecture conventions.
    # Validates that pages follow the presentation-layer pattern:
    # - No database queries
    # - No business logic
    # - No service layer access
    # - Required component methods implemented
    # - Plain Hash objects (no OpenStruct)
    #
    class Analyzer
      attr_reader :results, :total_pages, :compliant_count, :warning_count, :error_count

      def initialize
        @results = []
        @total_pages = 0
        @compliant_count = 0
        @warning_count = 0
        @error_count = 0
        @verbose = ENV["VERBOSE"] == "true"
      end

      # Analyze all pages in the app/pages directory
      # @return [void]
      def analyze_all
        page_files = find_all_pages
        @total_pages = page_files.count

        puts "Found #{@total_pages} page files to analyze..."
        puts

        page_files.each_with_index do |file_path, index|
          print "\rAnalyzing... #{index + 1}/#{@total_pages}" unless @verbose

          result = analyze_page(file_path)
          @results << result

          update_counters(result)

          if @verbose
            puts format_single_page_report(result)
            puts
          end
        end

        puts "\r" + (" " * 50) + "\r" unless @verbose
        generate_report
      end

      # Analyze a single page file
      # @param file_path [String] path to the page file
      # @return [Hash] analysis result
      def analyze_page(file_path)
        content = File.read(file_path)

        result = {
          file_path: file_path,
          class_name: extract_class_name(content),
          page_type: categorize_page_type(file_path),
          namespace: extract_namespace(file_path),
          issues: [],
          warnings: [],
          compliant: true
        }

        # Run all compliance checks
        check_page_structure(content, result)
        check_ui_configuration_only(content, result)
        check_template_system_compliance(content, result)
        check_architecture_compliance(content, result)
        check_hash_usage_patterns(content, result)

        # Determine overall compliance
        result[:compliant] = result[:issues].empty?
        result[:status] = if result[:issues].any?
                            :error
        elsif result[:warnings].any?
                            :warning
        else
                            :compliant
        end

        result
      rescue StandardError => e
        {
          file_path: file_path,
          class_name: "PARSE_ERROR",
          page_type: :unknown,
          namespace: "UNKNOWN",
          issues: [ "Parse error: #{e.message}" ],
          warnings: [],
          compliant: false,
          status: :error
        }
      end

      # Format a single page analysis result for display
      # @param result [Hash] analysis result
      # @return [String] formatted report
      def format_single_page_report(result)
        output = []
        status_icon = case result[:status]
        when :compliant then "[OK]"
        when :warning then "[WARN]"
        when :error then "[ERROR]"
        end

        output << "#{status_icon} #{result[:file_path]}"
        output << "   Class: #{result[:class_name]}" if result[:class_name] != "UNKNOWN"
        output << "   Type: #{result[:page_type]} | Namespace: #{result[:namespace]}" if result[:page_type] != :unknown

        if result[:issues].any?
          output << "   Issues:"
          result[:issues].each { |issue| output << "      - #{issue}" }
        end

        if result[:warnings].any?
          output << "   Warnings:"
          result[:warnings].each { |warning| output << "      - #{warning}" }
        end

        output.join("\n")
      end

      # Generate and print the final analysis report
      # @return [void]
      def generate_report
        puts "SUMMARY"
        puts "======="
        puts "Total pages analyzed: #{@total_pages}"
        puts "[OK] Fully compliant: #{@compliant_count} (#{percentage(@compliant_count)}%)"
        puts "[WARN] With warnings: #{@warning_count} (#{percentage(@warning_count)}%)"
        puts "[ERROR] With errors: #{@error_count} (#{percentage(@error_count)}%)"
        puts

        # Show critical issues
        error_results = @results.select { |r| r[:status] == :error }
        if error_results.any?
          puts "CRITICAL ISSUES"
          puts "==============="
          error_results.each do |result|
            puts "- #{result[:file_path]}"
            result[:issues].each { |issue| puts "  - #{issue}" }
          end
          puts
        end

        # Show warnings
        warning_results = @results.select { |r| r[:status] == :warning }
        if warning_results.any?
          puts "WARNINGS"
          puts "========"
          warning_results.each do |result|
            puts "- #{result[:file_path]}"
            result[:warnings].each { |warning| puts "  - #{warning}" }
          end
          puts
        end

        generate_recommendations
      end

      private

      def find_all_pages
        Dir.glob("app/pages/**/*_page.rb").sort
      end

      def extract_class_name(content)
        match = content.match(/class\s+([A-Za-z:]+Page)\s*/)
        match ? match[1] : "UNKNOWN"
      end

      def extract_namespace(file_path)
        parts = file_path.split("/")
        return "UNKNOWN" unless parts.include?("pages")

        pages_index = parts.index("pages")
        return "Root" if parts.length <= pages_index + 2

        parts[pages_index + 1].capitalize
      end

      def categorize_page_type(file_path)
        case file_path
        when %r{/base_page\.rb$}, %r{/application_page\.rb$}
          :base
        when %r{pages/[^/]+_page\.rb$}
          :root_page
        when %r{pages/\w+/\w+_page\.rb$}
          :namespaced_page
        when %r{/index_page\.rb$}
          :index_page
        when %r{/show_page\.rb$}
          :show_page
        when %r{/new_page\.rb$}
          :form_page
        when %r{/edit_page\.rb$}
          :form_page
        when %r{/custom_page\.rb$}
          :custom_page
        else
          :unknown
        end
      end

      def check_page_structure(content, result)
        # Check proper class naming
        class_name = result[:class_name]
        result[:issues] << 'Page class must end with "Page"' unless class_name.end_with?("Page")

        # Check namespace structure for namespaced pages
        if result[:page_type] == :namespaced_page
          expected_module = result[:namespace]
          unless content.match?(/module\s+#{expected_module}/i)
            result[:warnings] << "Expected module #{expected_module} for namespaced page"
          end
        end

        # Check for initialize method (required for non-base pages)
        return if content.include?("def initialize") || result[:page_type] == :base

        result[:issues] << "Page must have initialize method"
      end

      def check_ui_configuration_only(content, result)
        # Check for FORBIDDEN database access
        database_patterns = [
          { pattern: /\.find\(/, message: "Database queries forbidden in Page" },
          { pattern: /\.where\(/, message: "Database queries forbidden in Page" },
          { pattern: /\.all\b/, message: "Database queries forbidden in Page" },
          { pattern: /\.count\b/, message: "Database queries forbidden in Page" },
          { pattern: /\.joins\(/, message: "Database queries forbidden in Page" },
          { pattern: /\.includes\(/, message: "Database queries forbidden in Page" }
        ]

        database_patterns.each do |check|
          result[:issues] << check[:message] if content.match?(check[:pattern])
        end

        # Check for business logic (FORBIDDEN)
        business_logic_patterns = [
          { pattern: /def\s+calculate_/, message: "Business calculations forbidden in Page" },
          { pattern: /def\s+process_/, message: "Business processing forbidden in Page" },
          { pattern: /def\s+validate_(?!form_panels)/, message: "Validation logic forbidden in Page" },
          { pattern: /def\s+save_/, message: "Persistence operations forbidden in Page" }
        ]

        business_logic_patterns.each do |check|
          result[:issues] << check[:message] if content.match?(check[:pattern])
        end

        # Check for Service layer access (FORBIDDEN)
        if content.match?(/Service\.new|service\s*=.*Service/)
          result[:issues] << "Service layer access forbidden in Page"
        end

        # Check for external dependencies (FORBIDDEN)
        external_patterns = [
          /Net::HTTP/,
          /HTTParty/,
          /Faraday/,
          /Redis/
        ]

        external_patterns.each do |pattern|
          if content.match?(pattern)
            result[:issues] << "External dependencies forbidden in Page"
            break
          end
        end
      end

      def check_template_system_compliance(content, result)
        page_type = result[:page_type]

        # Check for required component methods based on page type
        # New pattern: simple method names matching registered components
        case page_type
        when :index_page
          required_methods = %w[header table]
          check_required_component_methods(content, result, required_methods)

        when :show_page
          required_methods = %w[header]
          check_required_component_methods(content, result, required_methods)

        when :form_page
          required_methods = %w[header panels]
          check_required_component_methods(content, result, required_methods)

        when :custom_page
          required_methods = %w[content]
          check_required_component_methods(content, result, required_methods)
        end

        # Check for main page method (index, show, new, edit, form, custom)
        page_methods = %w[index show new edit form custom]
        found_main_method = page_methods.any? { |method| content.include?("def #{method}") }

        return if found_main_method || result[:page_type] == :base

        result[:warnings] << "Page should have main method (index, show, form, or custom)"
      end

      def check_architecture_compliance(content, result)
        # Check for hardcoded paths (DISCOURAGED)
        if content.match?(%r{"/\w+})
          result[:warnings] << "Hardcoded paths detected - prefer Rails path helpers"
        end

        # Check for HTML generation (should be in components)
        html_patterns = [
          /<\w+/,
          /html_safe/,
          /raw\(/,
          /content_tag/
        ]

        html_patterns.each do |pattern|
          if content.match?(pattern)
            result[:warnings] << "HTML generation found - should be handled by template system"
            break
          end
        end
      end

      def check_hash_usage_patterns(content, result)
        # Check for OpenStruct usage (FORBIDDEN)
        if content.include?("OpenStruct") || content.include?("ostruct")
          result[:issues] << "OpenStruct usage forbidden - use plain Hash objects"
        end

        # Check for Struct usage (DISCOURAGED)
        if content.match?(/Struct\.new/)
          result[:warnings] << "Struct usage discouraged - prefer plain Hash for consistency"
        end
      end

      def check_required_component_methods(content, result, required_methods)
        required_methods.each do |method|
          unless content.include?("def #{method}")
            result[:issues] << "Missing required component method: #{method}"
          end
        end
      end

      def update_counters(result)
        case result[:status]
        when :compliant
          @compliant_count += 1
        when :warning
          @warning_count += 1
        when :error
          @error_count += 1
        end
      end

      def percentage(count)
        return 0 if @total_pages.zero?

        ((count.to_f / @total_pages) * 100).round(1)
      end

      def generate_recommendations
        puts "RECOMMENDATIONS"
        puts "==============="

        issues_by_type = {}
        @results.each do |result|
          (result[:issues] + result[:warnings]).each do |issue|
            issues_by_type[issue] ||= 0
            issues_by_type[issue] += 1
          end
        end

        if issues_by_type.any?
          puts "Top issues to address:"
          issues_by_type.sort_by { |_, count| -count }.first(5).each_with_index do |(issue, count), index|
            puts "#{index + 1}. #{issue} (#{count} pages affected)"
          end
        else
          puts "All pages are compliant!"
        end

        puts
        puts "NEXT STEPS:"

        if @error_count > 0
          puts "1. Remove database queries from Pages"
          puts "2. Remove business logic - keep UI configuration only"
          puts "3. Implement required component methods for template system"
        end

        if @warning_count > 0
          step = @error_count > 0 ? 4 : 1
          puts "#{step}. Replace OpenStruct with plain Hash objects"
          puts "#{step + 1}. Use Rails path helpers instead of hardcoded paths"
        end

        if @error_count.zero? && @warning_count.zero?
          puts "1. Consider implementing optional component methods for better UI"
        end
      end
    end
  end
end
