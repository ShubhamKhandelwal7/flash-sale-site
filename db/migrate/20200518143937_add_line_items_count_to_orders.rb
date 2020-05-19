class AddLineItemsCountToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :line_items_count, :integer
  end
end
