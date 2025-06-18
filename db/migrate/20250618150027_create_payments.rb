class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :payment_type
      t.boolean :payment_status

      t.timestamps
    end
  end
end
