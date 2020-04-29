class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.string :state
      t.string :city
      t.integer :pincode
      t.string :country
      t.boolean :default, default: false, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :addresses, :deleted_at
  end
end
