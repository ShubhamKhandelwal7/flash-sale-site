class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.string :transaction_id, null: false
      t.integer :state, default: 0, null: false
      t.string :method
      t.string :type
      t.integer :amount, null: false
      t.string :currency
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end

    add_index :payments, :transaction_id, unique: true
  end
end
