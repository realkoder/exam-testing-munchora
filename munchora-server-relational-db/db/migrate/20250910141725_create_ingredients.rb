# The `id` column, as the primary key, is automatically created by convention. Don't care about enumeration exploits here xD

class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name
      t.string :category
      t.integer :amount
      t.references :recipe, null: false, type: :string, limit: 36, foreign_key: true

      t.timestamps
    end
  end
end
