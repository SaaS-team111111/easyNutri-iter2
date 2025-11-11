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

ActiveRecord::Schema[7.1].define(version: 2025_11_11_024849) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actual_meal_entries", force: :cascade do |t|
    t.bigint "meal_plan_id", null: false
    t.integer "day_index", null: false
    t.string "meal_type", null: false
    t.bigint "food_item_id", null: false
    t.integer "grams", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_item_id"], name: "index_actual_meal_entries_on_food_item_id"
    t.index ["meal_plan_id", "day_index", "meal_type"], name: "idx_on_meal_plan_id_day_index_meal_type_76a201a913", unique: true
    t.index ["meal_plan_id"], name: "index_actual_meal_entries_on_meal_plan_id"
  end

  create_table "daily_trackings", force: :cascade do |t|
    t.bigint "meal_plan_id", null: false
    t.integer "day_index", null: false
    t.string "feedback", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_plan_id", "day_index"], name: "index_daily_trackings_on_meal_plan_id_and_day_index", unique: true
    t.index ["meal_plan_id"], name: "index_daily_trackings_on_meal_plan_id"
  end

  create_table "food_items", force: :cascade do |t|
    t.string "name"
    t.integer "calories_per_100g"
    t.float "protein_per_100g"
    t.float "carbs_per_100g"
    t.float "fat_per_100g"
    t.integer "sodium_mg_per_100g"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meal_entries", force: :cascade do |t|
    t.bigint "meal_plan_id", null: false
    t.bigint "food_item_id", null: false
    t.integer "day_index"
    t.string "meal_type"
    t.integer "grams"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_item_id"], name: "index_meal_entries_on_food_item_id"
    t.index ["meal_plan_id"], name: "index_meal_entries_on_meal_plan_id"
  end

  create_table "meal_plans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "goal"
    t.integer "duration_days"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_day", default: 0, null: false
    t.index ["user_id"], name: "index_meal_plans_on_user_id"
  end

  create_table "meal_recommendations", force: :cascade do |t|
    t.bigint "meal_plan_id", null: false
    t.integer "day_index", null: false
    t.string "meal_type", null: false
    t.bigint "food_item_id", null: false
    t.integer "recommended_grams", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_item_id"], name: "index_meal_recommendations_on_food_item_id"
    t.index ["meal_plan_id", "day_index", "meal_type"], name: "idx_on_meal_plan_id_day_index_meal_type_dba6b2ec7f"
    t.index ["meal_plan_id"], name: "index_meal_recommendations_on_meal_plan_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "height_cm"
    t.integer "weight_kg"
    t.integer "age"
    t.string "sex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "actual_meal_entries", "food_items"
  add_foreign_key "actual_meal_entries", "meal_plans"
  add_foreign_key "daily_trackings", "meal_plans"
  add_foreign_key "meal_entries", "food_items"
  add_foreign_key "meal_entries", "meal_plans"
  add_foreign_key "meal_plans", "users"
  add_foreign_key "meal_recommendations", "food_items"
  add_foreign_key "meal_recommendations", "meal_plans"
end
