class CreateRecipeSuggestions < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_suggestions do |t|
      t.references :user, null: false, foreign_key: true, type: :string, limit: 36
      t.references :recipe, null: false, foreign_key: true, type: :string, limit: 36
      t.string :reason
      t.timestamps
    end

    add_index :recipe_suggestions, [:user_id, :recipe_id], unique: true
  end
end
