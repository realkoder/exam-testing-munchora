class AddGenerateRecipeSuggestionsProcedure < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      CREATE PROCEDURE generate_recipe_suggestions(IN p_user_id VARCHAR(36))
      BEGIN
        DECLARE favorite_cuisines TEXT;
        DECLARE favorite_tags TEXT;

        -- Get user's favorite cuisines from liked recipes
        SELECT GROUP_CONCAT(DISTINCT JSON_UNQUOTE(JSON_EXTRACT(r.cuisine, '$[0]'))) INTO favorite_cuisines
        FROM recipes r
        WHERE r.id IN (
          SELECT recipe_id FROM recipe_likes WHERE user_id = p_user_id
        )
        AND r.cuisine IS NOT NULL
        LIMIT 5;

        -- Get user's favorite tags from liked recipes
        SELECT GROUP_CONCAT(DISTINCT JSON_UNQUOTE(JSON_EXTRACT(r.tags, '$[0]'))) INTO favorite_tags
        FROM recipes r
        WHERE r.id IN (
          SELECT recipe_id FROM recipe_likes WHERE user_id = p_user_id
        )
        AND r.tags IS NOT NULL
        LIMIT 8;

        -- Delete old suggestions for this user
        DELETE FROM recipe_suggestions WHERE user_id = p_user_id;

        -- Insert personalized recipe suggestions
        INSERT INTO recipe_suggestions (user_id, recipe_id, reason, created_at, updated_at)
        SELECT
          p_user_id,
          r.id,
          CASE
            WHEN favorite_cuisines IS NOT NULL
                 AND JSON_OVERLAPS(r.cuisine, JSON_ARRAY(favorite_cuisines))
                 THEN 'matches your favorite cuisine'
            WHEN favorite_tags IS NOT NULL
                 AND JSON_OVERLAPS(r.tags, JSON_ARRAY(favorite_tags))
                 THEN 'matches your favorite tags'
            WHEN (SELECT COUNT(*) FROM recipe_likes WHERE recipe_id = r.id) > 50
                 THEN 'highly popular recipe'
            WHEN (SELECT COUNT(*) FROM recipe_comments WHERE recipe_id = r.id) > 20
                 THEN 'highly discussed recipe'
            ELSE 'new recipe you might enjoy'
          END AS reason,
          NOW(),
          NOW()
        FROM recipes r
        WHERE r.id NOT IN (
          SELECT recipe_id FROM recipe_likes WHERE user_id = p_user_id
          UNION
          SELECT recipe_id FROM recipe_comments WHERE user_id = p_user_id
          UNION
          SELECT recipe_id FROM recipe_suggestions WHERE user_id = p_user_id
        )
        AND r.is_public = true
        ORDER BY
          CASE WHEN favorite_cuisines IS NOT NULL
               AND JSON_OVERLAPS(r.cuisine, JSON_ARRAY(favorite_cuisines)) THEN 1
               ELSE 0
          END DESC,
          CASE WHEN favorite_tags IS NOT NULL
               AND JSON_OVERLAPS(r.tags, JSON_ARRAY(favorite_tags)) THEN 1
               ELSE 0
          END DESC,
          (SELECT COUNT(*) FROM recipe_likes WHERE recipe_id = r.id) DESC,
          (SELECT COUNT(*) FROM recipe_comments WHERE recipe_id = r.id) DESC,
          r.created_at DESC
        LIMIT 15;
      END;
    SQL
  end

  def down
    execute <<~SQL
      DROP PROCEDURE IF EXISTS generate_recipe_suggestions;
    SQL
  end
end
