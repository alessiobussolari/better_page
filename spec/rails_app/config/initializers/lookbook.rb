# frozen_string_literal: true

if defined?(Lookbook)
  Lookbook.configure do |config|
    config.preview_paths = [Rails.root.join("test/components/previews")]
    config.preview_layout = "component_preview"
  end
end
