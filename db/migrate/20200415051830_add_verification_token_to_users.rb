class AddVerificationTokenToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :verification_token, :string
    add_column :users, :verification_token_sent_at, :datetime
    add_column :users, :verified_at, :datetime

    add_index :users, :verification_token, unique: true
  end
end
