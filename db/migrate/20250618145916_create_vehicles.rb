# frozen_string_literal: true

class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.references :driver, null: false, foreign_key: true
      t.string :vehicle_type
      t.string :model
      t.string :licence_plate
      t.integer :capacity

      t.timestamps
    end
  end
end
