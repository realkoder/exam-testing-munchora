class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :provider
      t.string :uid
      t.string :password_digest
      t.string :image_src
      t.string :bio
      t.datetime :last_signed_in_at

      t.timestamps
    end

    execute "ALTER TABLE users MODIFY id VARCHAR(36) DEFAULT (UUID()) NOT NULL;"

    # Create trigger to generate UUID on insert
    # execute <<~SQL
    #   CREATE TRIGGER before_users_insert
    #   BEFORE INSERT ON users
    #   FOR EACH ROW
    #   BEGIN
    #     IF NEW.id IS NULL OR NEW.id = '' THEN
    #       SET NEW.id = UUID();
    #     END IF;
    #   END;
    # SQL
  end
end
