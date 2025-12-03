# frozen_string_literal: true

module BetterPage
  module Common
    module Modal
      class HeaderComponent < BetterPage::ApplicationViewComponent
        def initialize(title:, modal_id: nil, show_close_button: true, **options)
          @title = title
          @modal_id = modal_id
          @show_close_button = show_close_button
          @options = options
        end

        attr_reader :title, :modal_id, :show_close_button, :options

        def title_id
          modal_id ? "modal-title-#{modal_id}" : nil
        end
      end
    end
  end
end
