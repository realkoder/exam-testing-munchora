class AddSchedulerForGeneratingRecipeSuggestions < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE EVENT weekly_recipe_suggestions
      ON SCHEDULE EVERY 6 HOUR
      STARTS CURRENT_TIMESTAMP
      DO
      BEGIN
        DECLARE done INT DEFAULT FALSE;
        DECLARE v_user_id VARCHAR(36);

        -- Cursor to select all user IDs
        DECLARE cur CURSOR FOR SELECT id FROM users;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        OPEN cur;

        read_loop: LOOP
          FETCH cur INTO v_user_id;
          IF done THEN
            LEAVE read_loop;
          END IF;

          -- Call the stored procedure for this user
          CALL generate_recipe_suggestions(v_user_id);
        END LOOP;

        CLOSE cur;
      END;
    SQL
  end

  def down
    execute "DROP EVENT IF EXISTS weekly_recipe_suggestions;"
  end
end
