class CreateDeals < ActiveRecord::Migration[6.0]
  def change
    enable_extension("citext")

    create_table :deals do |t|
      t.citext :title, null: false
      t.string :description
      t.decimal :price, precision: 8, scale: 2
      t.decimal :discount_price, default: "0.0", null: false
      t.integer :quantity, default: "0", null: false
      t.datetime :published_date
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :deals, :deleted_at
    add_index :deals, :title, unique: true
  end
end
