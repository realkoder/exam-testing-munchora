class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true, type: :string, limit: 36
      t.references :subscription_plan, null: false, foreign_key: true
      t.datetime :cancelled_at
      t.string :status

      t.timestamps
    end
  end
end
