class CreateOrderHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :order_histories do |t|
      t.references :order, null: false, foreign_key: true
      t.string :note
      t.integer :state  
      
      t.timestamps
    end
  end
end
