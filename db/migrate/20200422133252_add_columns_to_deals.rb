class AddColumnsToDeals < ActiveRecord::Migration[6.0]
  def change
    add_column :deals, :live_begin, :datetime
    add_column :deals, :live_end, :datetime
  end
end
