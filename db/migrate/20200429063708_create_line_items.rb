class CreateLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :line_items do |t|
      t.integer :quantity, default: 1, null: false
      t.decimal :price, precision: 8, scale: 2
      t.decimal :deal_discount_price, precision: 8, scale: 2
      t.decimal :loyalty_discount_price, precision: 8, scale: 2
      t.decimal :taxed_price, precision: 8, scale: 2
      t.references :order, null: false, foreign_key: true
      t.references :deal, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :line_items, :deleted_at
  end
end
