class ChangeColumnInPayments < ActiveRecord::Migration[6.0]
  def up
    rename_column :payments, :type, :category
  end

  def down
    rename_column :payments, :category, :type
  end
end
