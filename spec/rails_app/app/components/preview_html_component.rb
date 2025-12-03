# frozen_string_literal: true

# A simple component for rendering raw HTML in Lookbook previews.
# Used when previewing components that require partials.
class PreviewHtmlComponent < ViewComponent::Base
  def initialize(html:)
    @html = html
    super() # Call parent with no arguments
  end

  def call
    @html.html_safe
  end
end
