class CreateRecipeLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_likes do |t|
      t.references :user, null: false, foreign_key: true, type: :string, limit: 36
      t.references :recipe, null: false, foreign_key: true, type: :string, limit: 36

      t.timestamps
    end

    add_index :recipe_likes, [:user_id, :recipe_id], unique: true # Ensures each user can only like one recipe at a time
  end
end
