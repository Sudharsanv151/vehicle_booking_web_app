# frozen_string_literal: true

class AddDeletedAtToVehicles < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :deleted_at, :datetime
    add_index :vehicles, :deleted_at
  end
end
