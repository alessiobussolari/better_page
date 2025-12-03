# frozen_string_literal: true

module BetterPage
  module Page
    class CustomComponent < BetterPage::ApplicationViewComponent
        def initialize(custom_header: nil, custom_footer: nil, **options)
          @custom_header = custom_header
          @custom_footer = custom_footer
          @options = options
        end

        attr_reader :custom_header, :custom_footer, :options

        def should_render_header?
          custom_header.present?
        end

        def should_render_footer?
          custom_footer.present?
        end
    end
  end
end
