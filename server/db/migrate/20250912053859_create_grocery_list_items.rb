class CreateGroceryListItems < ActiveRecord::Migration[8.0]
  def change
    create_table :grocery_list_items do |t|
      t.string :name, null: false
      t.string :category
      t.boolean :is_completed, default: false
      t.references :grocery_list, null: false, type: :string, foreign_key: true, limit: 36
      t.references :added_by, foreign_key: { to_table: :users }, type: :string, limit: 36

      t.timestamps
    end
  end
end
