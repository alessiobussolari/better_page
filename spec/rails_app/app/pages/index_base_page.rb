# frozen_string_literal: true

class IndexBasePage < ApplicationPage
  page_type :index

  def index
    build_page
  end

  def view_component_class
    return BetterPage::IndexViewComponent if defined?(BetterPage::IndexViewComponent)

    raise NotImplementedError, "BetterPage::IndexViewComponent not found"
  end

  def stream_components
    %i[alerts statistics table pagination]
  end
end
