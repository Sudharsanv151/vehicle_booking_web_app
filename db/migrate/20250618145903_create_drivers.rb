# frozen_string_literal: true

class CreateDrivers < ActiveRecord::Migration[7.1]
  def change
    create_table :drivers do |t|
      t.string :licence_no

      t.timestamps
    end
  end
end
