class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    enable_extension("citext")

    create_table :users do |t|
      t.string :name, null: false
      t.citext :email, null: false
      t.string :password_digest, null: false
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :users, :deleted_at
    add_index :users, :email, unique: true
    add_index :users, :password_reset_token, unique: true
  end
end
