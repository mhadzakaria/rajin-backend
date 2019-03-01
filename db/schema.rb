# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_01_094840) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jobs", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "payment_term"
    t.integer "amount"
    t.string "payment_type"
    t.text "full_address"
    t.string "city"
    t.string "postcode"
    t.string "state"
    t.string "country"
    t.datetime "start_date"
    t.datetime "end_date"
    t.float "latitude"
    t.float "longitude"
    t.string "status"
    t.integer "job_category_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "nickname"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.datetime "date_of_birth"
    t.string "gender"
    t.text "full_address"
    t.string "city"
    t.integer "postcode"
    t.string "state"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.string "position"
    t.string "user_type"
    t.string "access_token"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_users_on_access_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["latitude"], name: "index_users_on_latitude"
    t.index ["longitude"], name: "index_users_on_longitude"
    t.index ["nickname"], name: "index_users_on_nickname"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_type"], name: "index_users_on_user_type"
  end

end
