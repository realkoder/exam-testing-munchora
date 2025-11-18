class CreateRecipeSummaryView < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE VIEW recipe_summary_view AS
      SELECT
        r.id,
        r.title AS recipe_title,
        r.created_at AS recipe_created_at,
        r.user_id AS creator_user_id,
        u.first_name AS creator_name,
        IFNULL(like_count.total_likes, 0) AS total_likes,
        IFNULL(comment_count.total_comments, 0) AS total_comments,
        IFNULL(ingredient_count.total_ingredients, 0) AS total_ingredients,
        IFNULL(likers.liked_users, '') AS liked_user_names,
        IFNULL(commenters.comments_with_names, '') AS comments_with_user_names
      FROM recipes r
      JOIN users u ON r.user_id = u.id
      -- Likes count
      LEFT JOIN (
        SELECT recipe_id, COUNT(*) AS total_likes
        FROM recipe_likes
        GROUP BY recipe_id
      ) like_count ON like_count.recipe_id = r.id
      -- Comments count
      LEFT JOIN (
        SELECT recipe_id, COUNT(*) AS total_comments
        FROM recipe_comments
        GROUP BY recipe_id
      ) comment_count ON comment_count.recipe_id = r.id
      -- Ingredients count
      LEFT JOIN (
        SELECT recipe_id, COUNT(*) AS total_ingredients
        FROM ingredients
        GROUP BY recipe_id
      ) ingredient_count ON ingredient_count.recipe_id = r.id
      -- Liked users
      LEFT JOIN (
        SELECT rl.recipe_id,
               GROUP_CONCAT(u.first_name SEPARATOR ', ') AS liked_users
        FROM recipe_likes rl
        JOIN users u ON rl.user_id = u.id
        GROUP BY rl.recipe_id
      ) likers ON likers.recipe_id = r.id
      -- Comments with comment creator names
      LEFT JOIN (
        SELECT rc.recipe_id,
               GROUP_CONCAT(CONCAT(u.first_name, ': ', rc.comment) SEPARATOR ' | ') AS comments_with_names
        FROM recipe_comments rc
        JOIN users u ON rc.user_id = u.id
        GROUP BY rc.recipe_id
      ) commenters ON commenters.recipe_id = r.id
      ORDER BY total_likes DESC;
    SQL
  end

  def down
    execute "DROP VIEW IF EXISTS recipe_summary_view;"
  end
end
