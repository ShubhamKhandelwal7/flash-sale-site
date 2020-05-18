class AddLockToDeals < ActiveRecord::Migration[6.0]
  def change
    add_column :deals, :lock_version, :integer, default: 0, null: false
  end
end
