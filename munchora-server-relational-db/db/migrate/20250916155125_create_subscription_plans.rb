class CreateSubscriptionPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.string :billing_cycle
      t.string :feature_description

      t.timestamps
    end
  end
end
