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

ActiveRecord::Schema[7.1].define(version: 2025_06_18_160032) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "vehicle_id", null: false
    t.string "start_location"
    t.string "end_location"
    t.float "price"
    t.datetime "booking_date"
    t.boolean "status", default: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean "ride_status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.index ["vehicle_id"], name: "index_bookings_on_vehicle_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "drivers", force: :cascade do |t|
    t.string "licence_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "payment_type"
    t.boolean "payment_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "stars"
    t.text "comments"
    t.string "rateable_type", null: false
    t.bigint "rateable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rateable_type", "rateable_id"], name: "index_ratings_on_rateable"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "points"
    t.string "reward_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_rewards_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags_vehicles", id: false, force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.bigint "vehicle_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password"
    t.string "mobile_no"
    t.string "userable_type", null: false
    t.bigint "userable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["userable_type", "userable_id"], name: "index_users_on_userable"
  end

  create_table "vehicles", force: :cascade do |t|
    t.bigint "driver_id", null: false
    t.string "vehicle_type"
    t.string "model"
    t.string "licence_plate"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_vehicles_on_driver_id"
  end

  add_foreign_key "bookings", "users"
  add_foreign_key "bookings", "vehicles"
  add_foreign_key "payments", "bookings"
  add_foreign_key "ratings", "users"
  add_foreign_key "rewards", "users"
  add_foreign_key "vehicles", "drivers"
end
