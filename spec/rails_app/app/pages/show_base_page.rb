# frozen_string_literal: true

class ShowBasePage < ApplicationPage
  page_type :show

  def show
    build_page
  end

  def view_component_class
    return BetterPage::ShowViewComponent if defined?(BetterPage::ShowViewComponent)

    raise NotImplementedError, "BetterPage::ShowViewComponent not found"
  end

  def stream_components
    %i[alerts statistics overview content_sections]
  end
end
