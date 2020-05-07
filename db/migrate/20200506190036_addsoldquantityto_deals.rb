class AddsoldquantitytoDeals < ActiveRecord::Migration[6.0]
  def change
    add_column :deals, :sold_quantity, :integer, default: 0, null: false
  end
end
