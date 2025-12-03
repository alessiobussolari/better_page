# frozen_string_literal: true

module BetterPage
  module Common
    class SearchComponent < BetterPage::ApplicationViewComponent
        def initialize(enabled: true, placeholder: "Search...", current_search: nil,
                       results_count: nil, filters: [], action_path: nil, **options)
          @enabled = enabled
          @placeholder = placeholder
          @current_search = current_search
          @results_count = results_count
          @filters = filters || []
          @action_path = action_path
          @options = options
        end

        attr_reader :enabled, :placeholder, :current_search, :results_count,
                    :filters, :action_path, :options

        def render?
          enabled
        end

        def has_filters?
          filters.present?
        end

        def has_active_filters?
          filters.any? { |f| f[:current_value].present? }
        end

        def form_action
          action_path || request.path
        end
    end
  end
end
