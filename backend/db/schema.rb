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

ActiveRecord::Schema[8.0].define(version: 2025_12_29_173317) do
  create_table "redemptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "reward_id", null: false
    t.integer "points_spent", null: false
    t.string "status", default: "completed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_redemptions_on_created_at"
    t.index ["reward_id"], name: "index_redemptions_on_reward_id"
    t.index ["user_id", "created_at"], name: "index_redemptions_on_user_and_date"
    t.index ["user_id"], name: "index_redemptions_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "cost", null: false
    t.string "image_url"
    t.string "category"
    t.integer "stock_quantity"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_rewards_on_active"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.integer "points_balance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "redemptions", "rewards"
  add_foreign_key "redemptions", "users"
end
