class CreateLlmUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_usages, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true

      t.references :user, null: false, type: :string, limit: 36, foreign_key: true
      t.references :recipe, null: false, type: :string, limit: 36, foreign_key: true
      t.string :provider
      t.string :model
      t.text :prompt
      t.integer :prompt_tokens
      t.integer :completion_tokens

      t.timestamps
    end

    execute "ALTER TABLE llm_usages MODIFY id VARCHAR(36) DEFAULT (UUID()) NOT NULL;"

    # Create trigger to generate UUID on insert
    # execute <<~SQL
    #   CREATE TRIGGER before_llm_usages_insert
    #   BEFORE INSERT ON llm_usages
    #   FOR EACH ROW
    #   BEGIN
    #     IF NEW.id IS NULL OR NEW.id = '' THEN
    #       SET NEW.id = UUID();
    #     END IF;
    #   END;
    # SQL
  end
end
