class CreateGroceryListShares < ActiveRecord::Migration[8.0]
  def change
    create_table :grocery_list_shares do |t|
      t.references :grocery_list, null: false, foreign_key: true, type: :string, limit: 36
      t.references :user, null: false, foreign_key: true, type: :string, limit: 36

      t.timestamps
    end

    add_index :grocery_list_shares, [:grocery_list_id, :user_id], unique: true
  end
end
