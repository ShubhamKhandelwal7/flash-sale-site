class AddcolumnstoLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :sale_price, :decimal, precision: 8, scale: 2
    add_column :line_items, :sub_total, :decimal, precision: 8, scale: 2
    add_column :line_items, :sub_tax_total, :decimal, precision: 8, scale: 2
  end
end
