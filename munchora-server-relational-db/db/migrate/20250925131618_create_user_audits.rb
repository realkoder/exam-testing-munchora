class CreateUserAudits < ActiveRecord::Migration[8.0]
  def up
    create_table :user_audits do |t|
      # UUID for user
      t.string :user_id
      t.string :operation
      t.json :old_data
      t.json :changed_data
      t.timestamps
    end

    execute <<-SQL
      CREATE TRIGGER users_audit_insert
      AFTER INSERT ON users
      FOR EACH ROW
      BEGIN
        INSERT INTO user_audits(user_id, operation, changed_data, created_at, updated_at)
        VALUES (NEW.id, 'INSERT',
          JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name, 'email', NEW.email, 'provider', NEW.provider, 'password_digest', NEW.password_digest, 'image_src', NEW.image_src, 'bio', NEW.bio, 'last_signed_in_at', NEW.last_signed_in_at, 'created_at', NEW.created_at),
          NOW(), NOW());
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER users_audit_update
      AFTER UPDATE ON users
      FOR EACH ROW
      BEGIN
        INSERT INTO user_audits(user_id, operation, old_data, changed_data, created_at, updated_at)
        VALUES (OLD.id, 'UPDATE',
          JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name, 'email', OLD.email, 'provider', OLD.provider, 'password_digest', OLD.password_digest, 'image_src', OLD.image_src, 'bio', OLD.bio, 'last_signed_in_at', OLD.last_signed_in_at, 'created_at', OLD.created_at),
          JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name, 'email', NEW.email, 'provider', NEW.provider, 'password_digest', NEW.password_digest, 'image_src', NEW.image_src, 'bio', NEW.bio, 'last_signed_in_at', NEW.last_signed_in_at, 'created_at', NEW.created_at),
          NOW(), NOW());
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER users_audit_delete
      AFTER DELETE ON users
      FOR EACH ROW
      BEGIN
        INSERT INTO user_audits(user_id, operation, old_data, created_at, updated_at)
        VALUES (OLD.id, 'DELETE',
          JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name, 'email', OLD.email, 'provider', OLD.provider, 'password_digest', OLD.password_digest, 'image_src', OLD.image_src, 'bio', OLD.bio, 'last_signed_in_at', OLD.last_signed_in_at, 'created_at', OLD.created_at),
          NOW(), NOW());
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS users_audit_insert;"
    execute "DROP TRIGGER IF EXISTS users_audit_update;"
    execute "DROP TRIGGER IF EXISTS users_audit_delete;"
    drop_table :user_audits
  end
end
