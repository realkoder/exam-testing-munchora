class AddCreateInvoiceTriggerToSubscriptions < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TRIGGER create_invoice_after_subscription_insert
      AFTER INSERT ON subscriptions
      FOR EACH ROW
      INSERT INTO invoices (user_id, subscription_id, amount, currency, status, period_start, period_end, created_at, updated_at)
      SELECT NEW.user_id, NEW.id, sp.price, 'USD', 'draft', NOW(),
             CASE
                 WHEN sp.billing_cycle = 'monthly' THEN DATE_ADD(NOW(), INTERVAL 1 MONTH)
                 WHEN sp.billing_cycle = 'yearly' THEN DATE_ADD(NOW(), INTERVAL 1 YEAR)
                 ELSE NOW()
                 END,
          NOW(), NOW()
      FROM subscription_plans sp
      WHERE sp.id = NEW.subscription_plan_id;
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS create_invoice_after_subscription_insert;
    SQL
  end
end
