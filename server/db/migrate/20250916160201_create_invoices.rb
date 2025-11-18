class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true, type: :string, limit: 36
      t.references :subscription, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency
      t.string :status
      t.datetime :paid_at
      t.datetime :period_start
      t.datetime :period_end

      t.timestamps
    end
  end
end
