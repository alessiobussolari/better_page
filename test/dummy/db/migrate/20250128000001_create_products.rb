# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.boolean :active, default: true
      t.integer :stock, default: 0

      t.timestamps
    end

    add_index :products, :name
    add_index :products, :active
  end
end
