# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_25_132239) do
  create_table "feedbacks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "message"
    t.string "name"
    t.string "email"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grocery_list_audits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "grocery_list_id"
    t.string "owner_id"
    t.string "operation"
    t.json "old_data"
    t.json "changed_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grocery_list_item_audits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "grocery_list_item_id"
    t.string "added_by_id"
    t.string "operation"
    t.json "old_data"
    t.json "changed_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grocery_list_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "category"
    t.boolean "is_completed", default: false
    t.string "grocery_list_id", limit: 36, null: false
    t.string "added_by_id", limit: 36
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_id"], name: "index_grocery_list_items_on_added_by_id"
    t.index ["grocery_list_id"], name: "index_grocery_list_items_on_grocery_list_id"
  end

  create_table "grocery_list_shares", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "grocery_list_id", limit: 36, null: false
    t.string "user_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grocery_list_id", "user_id"], name: "index_grocery_list_shares_on_grocery_list_id_and_user_id", unique: true
    t.index ["grocery_list_id"], name: "index_grocery_list_shares_on_grocery_list_id"
    t.index ["user_id"], name: "index_grocery_list_shares_on_user_id"
  end

  create_table "grocery_lists", id: { type: :string, limit: 36, default: -> { "(uuid())" } }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "owner_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_grocery_lists_on_owner_id"
  end

  create_table "ingredients", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.integer "amount"
    t.string "recipe_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_ingredients_on_recipe_id"
  end

  create_table "invoices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.bigint "subscription_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency"
    t.string "status"
    t.datetime "paid_at"
    t.datetime "period_start"
    t.datetime "period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "llm_usages", id: { type: :string, limit: 36, default: -> { "(uuid())" } }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36
    t.string "recipe_id", limit: 36, null: false
    t.string "provider"
    t.string "model"
    t.text "prompt"
    t.integer "prompt_tokens"
    t.integer "completion_tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_llm_usages_on_recipe_id"
    t.index ["user_id", "created_at"], name: "index_llm_usages_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_llm_usages_on_user_id"
  end

  create_table "recipe_comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.string "recipe_id", limit: 36, null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_comments_on_recipe_id"
    t.index ["user_id"], name: "index_recipe_comments_on_user_id"
  end

  create_table "recipe_likes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.string "recipe_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_likes_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_recipe_likes_on_user_id_and_recipe_id", unique: true
    t.index ["user_id"], name: "index_recipe_likes_on_user_id"
  end

  create_table "recipe_suggestions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.string "recipe_id", limit: 36, null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_suggestions_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_recipe_suggestions_on_user_id_and_recipe_id", unique: true
    t.index ["user_id"], name: "index_recipe_suggestions_on_user_id"
  end

  create_table "recipes", id: { type: :string, limit: 36, default: -> { "(uuid())" } }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.string "title"
    t.text "description"
    t.string "image_url"
    t.json "instructions"
    t.boolean "is_public", default: false
    t.json "cuisine"
    t.string "difficulty"
    t.json "tags"
    t.integer "prep_time", default: 10
    t.integer "cook_time", default: 10
    t.integer "servings", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "is_public"], name: "index_recipes_on_user_id_and_is_public"
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "subscription_plans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.decimal "price", precision: 10, scale: 2
    t.string "billing_cycle"
    t.string "feature_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.bigint "subscription_plan_id", null: false
    t.datetime "cancelled_at"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "user_audits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id"
    t.string "operation"
    t.json "old_data"
    t.json "changed_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: { type: :string, limit: 36, default: -> { "(uuid())" } }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "provider"
    t.string "uid"
    t.string "password_digest"
    t.string "image_src"
    t.string "bio"
    t.datetime "last_signed_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "grocery_list_items", "grocery_lists"
  add_foreign_key "grocery_list_items", "users", column: "added_by_id"
  add_foreign_key "grocery_list_shares", "grocery_lists"
  add_foreign_key "grocery_list_shares", "users"
  add_foreign_key "grocery_lists", "users", column: "owner_id"
  add_foreign_key "ingredients", "recipes"
  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "invoices", "users"
  add_foreign_key "llm_usages", "recipes"
  add_foreign_key "llm_usages", "users"
  add_foreign_key "recipe_comments", "recipes"
  add_foreign_key "recipe_comments", "users"
  add_foreign_key "recipe_likes", "recipes"
  add_foreign_key "recipe_likes", "users"
  add_foreign_key "recipe_suggestions", "recipes"
  add_foreign_key "recipe_suggestions", "users"
  add_foreign_key "recipes", "users"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "users"
end
