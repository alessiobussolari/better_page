# frozen_string_literal: true

module BetterPage
  module Common
    module Modal
      class ContentComponent < BetterPage::ApplicationViewComponent
        def initialize(custom_partial: nil, partial_locals: {}, **options)
          @custom_partial = custom_partial
          @partial_locals = partial_locals
          @options = options
        end

        attr_reader :custom_partial, :partial_locals, :options

        def render?
          custom_partial.present? || content.present?
        end
      end
    end
  end
end
