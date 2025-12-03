# frozen_string_literal: true

module BetterPage
  module Common
    class PaginationComponent < BetterPage::ApplicationViewComponent
        def initialize(enabled: true, current_page: 1, total_pages: 1, start_record: nil,
                       end_record: nil, total_records: nil, per_page: 25, default_per_page: 25,
                       base_path: nil, **options)
          @enabled = enabled
          @current_page = current_page.to_i
          @total_pages = total_pages.to_i
          @start_record = start_record
          @end_record = end_record
          @total_records = total_records
          @per_page = per_page
          @default_per_page = default_per_page
          @base_path = base_path
          @options = options
        end

        attr_reader :enabled, :current_page, :total_pages, :start_record, :end_record,
                    :total_records, :per_page, :default_per_page, :base_path, :options

        def render?
          enabled && total_pages > 1
        end

        def has_previous_page?
          current_page > 1
        end

        def has_next_page?
          current_page < total_pages
        end

        def previous_page_path
          build_page_path(current_page - 1)
        end

        def next_page_path
          build_page_path(current_page + 1)
        end

        def page_path(page_number)
          build_page_path(page_number)
        end

        def results_info_text
          return "" unless start_record && end_record && total_records

          "Showing #{start_record} - #{end_record} of #{total_records} results"
        end

        def pagination_page_numbers
          return [] if total_pages <= 1

          result = []

          if total_pages <= 7
            (1..total_pages).each do |page|
              result << { type: :page, number: page, current: page == current_page }
            end
          else
            result << { type: :page, number: 1, current: current_page == 1 }
            result << { type: :gap } if current_page > 4

            start_range = [current_page - 1, 2].max
            end_range = [current_page + 1, total_pages - 1].min

            (start_range..end_range).each do |page|
              result << { type: :page, number: page, current: page == current_page }
            end

            result << { type: :gap } if current_page < total_pages - 3

            unless total_pages <= end_range
              result << { type: :page, number: total_pages, current: current_page == total_pages }
            end
          end

          result
        end

        private

        def build_page_path(page)
          path = base_path || request.path
          params = request.query_parameters.dup
          params[:page] = page
          params[:per_page] = per_page if per_page != default_per_page

          query = params.to_query
          query.present? ? "#{path}?#{query}" : path
        end
      end
  end
end
