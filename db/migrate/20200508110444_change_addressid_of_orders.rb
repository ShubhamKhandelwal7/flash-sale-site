class ChangeAddressidOfOrders < ActiveRecord::Migration[6.0]
  def change
    change_column_null :orders, :address_id, true
  end
end
