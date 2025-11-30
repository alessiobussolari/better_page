# frozen_string_literal: true

namespace :better_page do
  desc "Analyze all pages for compliance with architecture conventions"
  task analyze: :environment do
    require "better_page/compliance/analyzer"

    puts "PAGE COMPLIANCE ANALYSIS"
    puts "========================"
    puts

    analyzer = BetterPage::Compliance::Analyzer.new
    analyzer.analyze_all

    puts
    puts "Analysis completed!"
    puts "Use VERBOSE=true for detailed output: bin/rails better_page:analyze VERBOSE=true"
  end

  desc "Analyze a specific page file for compliance"
  task :analyze_page, [ :file_path ] => :environment do |_t, args|
    require "better_page/compliance/analyzer"

    if args[:file_path].blank?
      puts "Please provide a page file path:"
      puts "   bin/rails better_page:analyze_page[app/pages/admin/users/index_page.rb]"
      exit 1
    end

    unless File.exist?(args[:file_path])
      puts "File not found: #{args[:file_path]}"
      exit 1
    end

    puts "Analyzing: #{args[:file_path]}"
    puts "========================="
    puts

    analyzer = BetterPage::Compliance::Analyzer.new
    result = analyzer.analyze_page(args[:file_path])

    puts analyzer.format_single_page_report(result)
    puts

    # Additional details for single page analysis
    case result[:status]
    when :compliant
      puts "This page follows all architectural patterns!"
      puts
      puts "COMPLIANCE CHECKLIST:"
      puts "  [OK] UI configuration only (no business logic)"
      puts "  [OK] No database access"
      puts "  [OK] Template system integration"
      puts "  [OK] Required build_* methods implemented"
      puts "  [OK] Plain Hash objects (no OpenStruct)"
    when :warning
      puts "This page has some areas for improvement:"
      puts "SUGGESTED IMPROVEMENTS:"
      result[:warnings].each { |warning| puts "  - #{warning}" }
    when :error
      puts "This page has critical compliance issues:"
      puts "REQUIRED FIXES:"
      result[:issues].each { |issue| puts "  - #{issue}" }
      if result[:warnings].any?
        puts "ADDITIONAL IMPROVEMENTS:"
        result[:warnings].each { |warning| puts "  - #{warning}" }
      end
    end
  end
end
