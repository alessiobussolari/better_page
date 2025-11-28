# frozen_string_literal: true

class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def formatted_price
    "$#{price.to_f.round(2)}"
  end

  def status
    active? ? "Active" : "Inactive"
  end
end
