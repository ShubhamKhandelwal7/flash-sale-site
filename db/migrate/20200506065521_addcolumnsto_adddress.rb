class AddcolumnstoAdddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :home_address, :text
    add_column :addresses, :token, :string

    add_index :addresses, :token, unique: true

  end
end
