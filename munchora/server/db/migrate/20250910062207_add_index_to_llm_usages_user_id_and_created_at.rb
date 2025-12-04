class AddIndexToLlmUsagesUserIdAndCreatedAt < ActiveRecord::Migration[8.0]
  def change
    add_index :llm_usages, [:user_id, :created_at]
  end
end
