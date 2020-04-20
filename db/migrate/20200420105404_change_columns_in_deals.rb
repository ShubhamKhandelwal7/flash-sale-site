class ChangeColumnsInDeals < ActiveRecord::Migration[6.0]
  def change
    change_column :deals, :description, :text
    change_column :deals, :discount_price, :decimal, precision: 8, scale: 2
    rename_column :deals, :published_date, :published_at
  end
end
