class AddIndexToUsers < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :authentication_token, unique: true
  end
end
