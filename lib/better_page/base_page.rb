# frozen_string_literal: true

module BetterPage
  # Base class for all page objects.
  # Pages are presentation-layer classes that configure UI without business logic.
  #
  # Rules:
  # - No database queries
  # - No business logic
  # - No service layer access
  # - UI configuration only (Hash-based structures)
  #
  # Components are registered using the DSL:
  #   register_component :header, required: true do
  #     required(:title).filled(:string)
  #   end
  #
  class BasePage
    include Rails.application.routes.url_helpers
    include ComponentRegistry

    attr_reader :user, :items, :stats, :item, :primary_data, :metadata

    # @param primary_data [Object] The main data for the page (e.g., collection, record)
    # @param metadata [Hash] Additional metadata (user, stats, item, etc.)
    def initialize(primary_data, metadata = {})
      @primary_data = primary_data
      @metadata = metadata
      @items = primary_data
      @user = metadata[:user]
      @stats = metadata[:stats]
      @item = metadata[:item]
    end

    protected

    # Helper for pluralized count text
    # @param count [Integer] the count
    # @param singular [String] singular form
    # @param plural [String] plural form
    # @return [String] formatted count text
    def count_text(count, singular, plural)
      "#{count} #{count == 1 ? singular : plural}"
    end

    # Helper for formatted dates
    # @param date [Date, Time, nil] the date to format
    # @param format [String] strftime format string
    # @return [String] formatted date or default message
    def format_date(date, format = "%d/%m/%Y")
      return "N/A" unless date

      date.strftime(format)
    end

    # Helper for percentage calculation
    # @param part [Numeric] the part value
    # @param total [Numeric] the total value
    # @return [Float] percentage rounded to 1 decimal
    def percentage(part, total)
      return 0 if total.zero?

      ((part.to_f / total) * 100).round(1)
    end

    # Helper for empty state with action
    # @param icon [String] icon name
    # @param title [String] title text
    # @param message [String] message text
    # @param action_label [String, nil] action button label
    # @param action_path [String, nil] action button path
    # @param action_icon [String] action button icon
    # @return [Hash] empty state configuration
    def empty_state_with_action(icon:, title:, message:, action_label: nil, action_path: nil, action_icon: "plus")
      state = {
        icon: icon,
        title: title,
        message: message
      }

      if action_label && action_path
        state[:action] = {
          label: action_label,
          path: action_path,
          icon: action_icon
        }
      end

      state
    end

    # Default breadcrumbs configuration
    # Override in subclasses for custom breadcrumbs
    # @return [Array<Hash>] breadcrumbs array
    def breadcrumbs_config
      []
    end

    # Default metadata configuration
    # @return [Array<Hash>] metadata array
    def default_metadata
      []
    end

    # Default actions configuration
    # @return [Array<Hash>] actions array
    def default_actions
      []
    end

    # Default alerts configuration
    # @return [Array<Hash>] alerts array
    def default_alerts
      []
    end

    # Default statistics configuration
    # @return [Array<Hash>] statistics array
    def default_statistics
      []
    end

    # Default tabs configuration
    # @return [Hash] tabs configuration
    def default_tabs_config
      {
        enabled: false,
        current_tab: "all",
        tabs: []
      }
    end

    # Default table configuration
    # @return [Hash] table configuration
    def default_table_config
      {
        items: @items || [],
        empty_state: {
          icon: "inbox",
          title: "No items found",
          message: "There are no items to display at the moment."
        },
        columns: [],
        actions: {
          type: :button_group,
          buttons: []
        }
      }
    end

    # Default footer info configuration
    # @return [Hash] footer configuration
    def default_footer_info
      {
        enabled: false,
        title: "Information",
        sections: []
      }
    end
  end
end
