# frozen_string_literal: true

module BetterPage
  module Common
    class FooterComponent < BetterPage::ApplicationViewComponent
        def initialize(enabled: true, actions: [], text: nil, **options)
          @enabled = enabled
          @actions = actions
          @text = text
          @options = options
        end

        attr_reader :enabled, :actions, :text, :options

        def render?
          enabled && (actions.present? || text.present?)
        end

        def has_actions?
          actions.present?
        end

        def has_text?
          text.present?
        end
    end
  end
end
