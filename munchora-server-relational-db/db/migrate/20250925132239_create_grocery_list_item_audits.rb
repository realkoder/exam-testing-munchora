class CreateGroceryListItemAudits < ActiveRecord::Migration[8.0]
  def up
    # Create the audit table
    create_table :grocery_list_item_audits do |t|
      t.string :grocery_list_item_id
      t.string :added_by_id
      t.string :operation
      t.json :old_data
      t.json :changed_data
      t.timestamps
    end

    # Trigger for INSERT
    execute <<-SQL
      CREATE TRIGGER grocery_list_items_audit_insert
      AFTER INSERT ON grocery_list_items
      FOR EACH ROW
      BEGIN
        INSERT INTO grocery_list_item_audits(grocery_list_item_id, added_by_id, operation, changed_data, created_at, updated_at)
        VALUES (NEW.id, NEW.added_by_id, 'INSERT',
          JSON_OBJECT('name', NEW.name, 'category', NEW.category, 'created_at', NEW.created_at),
          NOW(), NOW());
      END;
    SQL

    # Trigger for UPDATE
    execute <<-SQL
      CREATE TRIGGER grocery_list_items_audit_update
      AFTER UPDATE ON grocery_list_items
      FOR EACH ROW
      BEGIN
        INSERT INTO grocery_list_item_audits(grocery_list_item_id, added_by_id, operation, old_data, changed_data, created_at, updated_at)
        VALUES (OLD.id, OLD.added_by_id, 'UPDATE',
          JSON_OBJECT('name', OLD.name, 'category', OLD.category, 'created_at', OLD.created_at),
          JSON_OBJECT('name', NEW.name, 'category', NEW.category, 'created_at', NEW.created_at),
          NOW(), NOW());
      END;
    SQL

    # Trigger for DELETE
    execute <<-SQL
      CREATE TRIGGER grocery_list_items_audit_delete
      AFTER DELETE ON grocery_list_items
      FOR EACH ROW
      BEGIN
        INSERT INTO grocery_list_item_audits(grocery_list_item_id, added_by_id, operation, old_data, created_at, updated_at)
        VALUES (OLD.id, OLD.added_by_id, 'DELETE',
          JSON_OBJECT('name', OLD.name, 'category', OLD.category, 'created_at', OLD.created_at),
          NOW(), NOW());
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS grocery_list_items_audit_insert;"
    execute "DROP TRIGGER IF EXISTS grocery_list_items_audit_update;"
    execute "DROP TRIGGER IF EXISTS grocery_list_items_audit_delete;"
    drop_table :grocery_list_item_audits
  end
end
