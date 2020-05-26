class AddColumnsToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :stripe_response, :jsonb
    add_column :payments, :card_last_digits, :integer
    add_column :payments, :card_exp_year, :integer
    add_column :payments, :card_exp_month, :integer
    add_column :payments, :card_brand, :string
  end
end
