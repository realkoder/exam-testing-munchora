class CreateRecipeComments < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_comments do |t|
      t.references :user, null: false, foreign_key: true, type: :string, limit: 36
      t.references :recipe, null: false, foreign_key: true, type: :string, limit: 36
      t.text :comment

      t.timestamps
    end
  end
end
