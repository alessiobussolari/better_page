# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage do
  it "has a version number" do
    expect(BetterPage::VERSION).not_to be_nil
  end
end
