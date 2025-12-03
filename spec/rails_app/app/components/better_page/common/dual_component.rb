# frozen_string_literal: true

module BetterPage
  module Common
    class DualComponent < BetterPage::ApplicationViewComponent
        renders_one :left_panel
        renders_one :right_panel

        def initialize(enabled: true, left_panel_config: {}, right_panel_config: {}, ratio: "1:2", **options)
          @enabled = enabled
          @left_panel_config = left_panel_config
          @right_panel_config = right_panel_config
          @ratio = ratio
          @options = options
        end

        attr_reader :enabled, :left_panel_config, :right_panel_config, :ratio, :options

        def render?
          enabled
        end

        def left_panel_classes
          case ratio
          when "1:1" then "lg:w-1/2"
          when "1:2" then "lg:w-1/3"
          when "2:1" then "lg:w-2/3"
          when "1:3" then "lg:w-1/4"
          when "3:1" then "lg:w-3/4"
          else "lg:w-1/3"
          end
        end

        def right_panel_classes
          case ratio
          when "1:1" then "lg:w-1/2"
          when "1:2" then "lg:w-2/3"
          when "2:1" then "lg:w-1/3"
          when "1:3" then "lg:w-3/4"
          when "3:1" then "lg:w-1/4"
          else "lg:w-2/3"
          end
        end
    end
  end
end
