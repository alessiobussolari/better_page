# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "rails_app/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("rails_app/db/migrate", __dir__)]

require "rspec/rails"
require "view_component/test_helpers"
require "capybara/rspec"

# Load fixtures from the engine
RSpec.configure do |config|
  config.fixture_paths = [File.expand_path("fixtures", __dir__)]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # ViewComponent test helpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
end

# Mock ViewComponent classes for testing
# These simulate the ViewComponents that would be installed by the generator
module BetterPage
  class IndexViewComponent
    attr_reader :config

    def initialize(config:)
      @config = config
    end
  end

  class ShowViewComponent
    attr_reader :config

    def initialize(config:)
      @config = config
    end
  end

  class FormViewComponent
    attr_reader :config

    def initialize(config:)
      @config = config
    end
  end

  class CustomViewComponent
    attr_reader :config

    def initialize(config:)
      @config = config
    end
  end
end
