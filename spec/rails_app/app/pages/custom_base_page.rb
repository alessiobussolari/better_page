# frozen_string_literal: true

class CustomBasePage < ApplicationPage
  page_type :custom

  def custom
    build_page
  end

  def view_component_class
    return BetterPage::CustomViewComponent if defined?(BetterPage::CustomViewComponent)

    raise NotImplementedError, "BetterPage::CustomViewComponent not found"
  end

  def stream_components
    %i[alerts content]
  end
end
