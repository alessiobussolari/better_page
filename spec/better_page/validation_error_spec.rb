# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::ValidationError do
  it "inherits from StandardError" do
    expect(described_class.superclass).to eq(StandardError)
  end

  it "can be raised and caught" do
    expect {
      raise described_class, "Component validation failed"
    }.to raise_error(described_class, "Component validation failed")
  end

  it "can be caught as StandardError" do
    expect {
      raise described_class, "Test error"
    }.to raise_error(StandardError)
  end

  it "preserves error message" do
    error = described_class.new("Custom error message")
    expect(error.message).to eq("Custom error message")
  end
end
