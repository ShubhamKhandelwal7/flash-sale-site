class AddFieldsToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :paid_at, :datetime
    add_column :payments, :refunded_at, :datetime
  end
end
