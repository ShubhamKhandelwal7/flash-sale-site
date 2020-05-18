class AddTaxToDeals < ActiveRecord::Migration[6.0]
  def change
    add_column :deals, :tax, :decimal
  end
end
