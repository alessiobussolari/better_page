# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage do
  describe "VERSION" do
    it "has a version number" do
      expect(BetterPage::VERSION).not_to be_nil
    end

    it "follows semantic versioning format" do
      expect(BetterPage::VERSION).to match(/\A\d+\.\d+\.\d+/)
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(BetterPage.configuration).to be_a(BetterPage::Configuration)
    end

    it "returns the same instance on multiple calls" do
      config1 = BetterPage.configuration
      config2 = BetterPage.configuration

      expect(config1).to be(config2)
    end
  end

  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| BetterPage.configure(&b) }.to yield_with_args(BetterPage::Configuration)
    end

    it "allows registering components" do
      BetterPage.configure do |config|
        config.register_component :test_component, default: { enabled: true }
      end

      expect(BetterPage.configuration.component(:test_component)).not_to be_nil
    end

    it "returns the configuration" do
      result = BetterPage.configure { |_| }

      expect(result).to be_a(BetterPage::Configuration)
    end
  end

  describe ".reset_configuration!" do
    it "creates a new configuration instance" do
      old_config = BetterPage.configuration
      BetterPage.reset_configuration!
      new_config = BetterPage.configuration

      # Re-register defaults for other tests
      BetterPage::DefaultComponents.register!

      expect(new_config).not_to be(old_config)
    end
  end

  describe ".defaults_registered?" do
    it "returns true after defaults are registered" do
      expect(BetterPage.defaults_registered?).to be true
    end
  end

  describe ".defaults_registered!" do
    it "marks defaults as registered" do
      # Save current state
      original_state = BetterPage.instance_variable_get(:@defaults_registered)

      # Reset and test
      BetterPage.instance_variable_set(:@defaults_registered, false)
      expect(BetterPage.defaults_registered?).to be false

      BetterPage.defaults_registered!
      expect(BetterPage.defaults_registered?).to be true

      # Restore
      BetterPage.instance_variable_set(:@defaults_registered, original_state)
    end
  end

  describe "autoloaded classes" do
    it "autoloads ValidationError" do
      expect(BetterPage::ValidationError).to be_a(Class)
    end

    it "autoloads Config" do
      expect(BetterPage::Config).to be_a(Class)
    end

    it "autoloads ComponentRegistry" do
      expect(BetterPage::ComponentRegistry).to be_a(Module)
    end

    it "autoloads Configuration" do
      expect(BetterPage::Configuration).to be_a(Class)
    end

    it "autoloads DefaultComponents" do
      expect(BetterPage::DefaultComponents).to be_a(Module)
    end

    it "autoloads BasePage" do
      expect(BetterPage::BasePage).to be_a(Class)
    end

    it "autoloads IndexBasePage" do
      expect(BetterPage::IndexBasePage).to be_a(Class)
    end

    it "autoloads ShowBasePage" do
      expect(BetterPage::ShowBasePage).to be_a(Class)
    end

    it "autoloads FormBasePage" do
      expect(BetterPage::FormBasePage).to be_a(Class)
    end

    it "autoloads CustomBasePage" do
      expect(BetterPage::CustomBasePage).to be_a(Class)
    end

    it "autoloads Compliance::Analyzer" do
      expect(BetterPage::Compliance::Analyzer).to be_a(Class)
    end
  end
end
