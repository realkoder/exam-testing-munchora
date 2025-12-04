class CreateGroceryLists < ActiveRecord::Migration[8.0]
  def change
    create_table :grocery_lists, id: false do |t|
      t.binary :id, limit: 16, null: false, primary_key: true
      t.string :name
      t.references :owner, null: false, foreign_key: { to_table: :users }, type: :string, limit: 36

      t.timestamps
    end

    execute "ALTER TABLE grocery_lists MODIFY id VARCHAR(36) DEFAULT (UUID()) NOT NULL;"
  end
end
