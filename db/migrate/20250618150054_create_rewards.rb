# frozen_string_literal: true

class CreateRewards < ActiveRecord::Migration[7.1]
  def change
    create_table :rewards do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :points
      t.string :reward_type

      t.timestamps
    end
  end
end
