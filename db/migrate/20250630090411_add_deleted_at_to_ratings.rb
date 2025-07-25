# frozen_string_literal: true

class AddDeletedAtToRatings < ActiveRecord::Migration[7.1]
  def change
    add_column :ratings, :deleted_at, :datetime
    add_index :ratings, :deleted_at
  end
end
