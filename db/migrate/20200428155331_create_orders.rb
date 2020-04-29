class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.decimal :total_amount
      t.decimal :total_tax
      t.references :address, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :orders, :deleted_at
  end
end
