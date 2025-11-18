class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true

      t.references :user, null: false, type: :string, limit: 36, foreign_key: true
      t.string :title
      t.text :description
      t.string :image_url
      t.json :instructions
      t.boolean :is_public, default: false
      t.json :cuisine
      t.string :difficulty
      t.json :tags
      t.integer :prep_time, default: 10
      t.integer :cook_time, default: 10
      t.integer :servings, default: 1

      t.timestamps
    end

    execute "ALTER TABLE recipes MODIFY id VARCHAR(36) DEFAULT (UUID()) NOT NULL;"

    # Create trigger to generate UUID on insert
    # execute <<~SQL
    #   CREATE TRIGGER before_recipes_insert
    #   BEFORE INSERT ON recipes
    #   FOR EACH ROW
    #   BEGIN
    #     IF NEW.id IS NULL OR NEW.id = '' THEN
    #       SET NEW.id = UUID();
    #     END IF;
    #   END;
    # SQL

    add_index :recipes, [:user_id, :is_public]
  end
end
