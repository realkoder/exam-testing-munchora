class AddIndexesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_index :users, [:provider, :uid], unique: true # Ensuring quick access for SSO
    add_index :users, :email, unique: true
    add_index :users, :first_name
    add_index :users, :last_name
  end
end
