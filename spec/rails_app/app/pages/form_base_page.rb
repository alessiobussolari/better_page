# frozen_string_literal: true

class FormBasePage < ApplicationPage
  page_type :form

  def form
    build_page
  end

  def view_component_class
    return BetterPage::FormViewComponent if defined?(BetterPage::FormViewComponent)

    raise NotImplementedError, "BetterPage::FormViewComponent not found"
  end

  def stream_components
    %i[alerts errors panels]
  end
end
