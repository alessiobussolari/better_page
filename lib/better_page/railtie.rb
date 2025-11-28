# frozen_string_literal: true

module BetterPage
  class Railtie < ::Rails::Railtie
    # Add app/pages to the autoload paths
    # Must run before :set_autoload_paths to avoid FrozenError in Rails 8+
    initializer "better_page.autoload_paths", before: :set_autoload_paths do |app|
      pages_path = Rails.root.join("app", "pages")
      if pages_path.exist?
        app.config.autoload_paths << pages_path.to_s
        app.config.eager_load_paths << pages_path.to_s
      end
    end

    # Load rake tasks
    rake_tasks do
      load "tasks/better_page.rake"
    end

    # Add generators path
    generators do
      require "generators/better_page/install_generator"
      require "generators/better_page/page_generator"
    end
  end
end
