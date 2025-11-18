class CreateGroceryListAudits < ActiveRecord::Migration[8.0]
  def up
    create_table :grocery_list_audits do |t|
      # UUID foreign key for grocery_list
      t.string :grocery_list_id
      # UUID foreign key for owner (users table)
      t.string :owner_id
      t.string :operation
      t.json :old_data
      t.json :changed_data
      t.timestamps
    end

    # Trigger for INSERT
    execute <<-SQL
      CREATE TRIGGER grocery_lists_audit_insert
      AFTER INSERT ON grocery_lists
      FOR EACH ROW
      BEGIN
        INSERT INTO grocery_list_audits(grocery_list_id, owner_id, operation, changed_data, created_at, updated_at)
        VALUES (NEW.id, NEW.owner_id, 'INSERT',
          JSON_OBJECT('name', NEW.name, 'created_at', NEW.created_at),
          NOW(), NOW());
      END;
    SQL

    # Trigger for UPDATE
    execute <<-SQL
      CREATE TRIGGER grocery_lists_audit_update
      AFTER UPDATE ON grocery_lists
      FOR EACH ROW
      BEGIN
        INSERT INTO grocery_list_audits(grocery_list_id, owner_id, operation, old_data, changed_data, created_at, updated_at)
        VALUES (OLD.id, OLD.owner_id, 'UPDATE',
          JSON_OBJECT('name', OLD.name, 'created_at', OLD.created_at),
          JSON_OBJECT('name', NEW.name, 'created_at', NEW.created_at),
          NOW(), NOW());
      END;
    SQL

    # Trigger for DELETE
    execute <<-SQL
      CREATE TRIGGER grocery_lists_audit_delete
      AFTER DELETE ON grocery_lists
      FOR EACH ROW
      BEGIN
        INSERT INTO grocery_list_audits(grocery_list_id, owner_id, operation, old_data, created_at, updated_at)
        VALUES (OLD.id, OLD.owner_id, 'DELETE',
          JSON_OBJECT('name', OLD.name, 'created_at', OLD.created_at),
          NOW(), NOW());
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS grocery_lists_audit_insert;"
    execute "DROP TRIGGER IF EXISTS grocery_lists_audit_update;"
    execute "DROP TRIGGER IF EXISTS grocery_lists_audit_delete;"
    drop_table :grocery_list_audits
  end
end
