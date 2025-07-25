# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :mobile_no
      t.references :userable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
