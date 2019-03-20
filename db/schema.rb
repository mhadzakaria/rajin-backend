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

ActiveRecord::Schema.define(version: 2019_03_05_014321) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coin_balances", force: :cascade do |t|
    t.integer "user_id"
    t.integer "amount"
    t.string "coinable_type"
    t.bigint "coinable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coinable_type", "coinable_id"], name: "index_coin_balances_on_coinable_type_and_coinable_id"
    t.index ["user_id"], name: "index_coin_balances_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "phone_number"
    t.text "full_address"
    t.string "city"
    t.integer "postcode"
    t.string "state"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configs", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "email_notif"
    t.boolean "receive_notif"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_configs_on_user_id"
  end

  create_table "job_categories", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_job_categories_on_parent_id"
  end

  create_table "job_requests", force: :cascade do |t|
    t.integer "user_id"
    t.integer "job_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id", "user_id"], name: "index_job_requests_on_job_id_and_user_id", unique: true
    t.index ["job_id"], name: "index_job_requests_on_job_id"
    t.index ["user_id"], name: "index_job_requests_on_user_id"
  end

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
    t.string "ownerable_type"
    t.bigint "ownerable_id"
    t.text "skill_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_category_id"], name: "index_jobs_on_job_category_id"
    t.index ["ownerable_type", "ownerable_id"], name: "index_jobs_on_ownerable_type_and_ownerable_id"
  end

  create_table "mentors", force: :cascade do |t|
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
    t.integer "company_id"
    t.string "position"
    t.float "latitude"
    t.float "longitude"
    t.string "user_type"
    t.string "access_token"
    t.string "uuid"
    t.text "skill_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_mentors_on_access_token"
    t.index ["company_id"], name: "index_mentors_on_company_id"
    t.index ["email"], name: "index_mentors_on_email", unique: true
    t.index ["latitude"], name: "index_mentors_on_latitude"
    t.index ["longitude"], name: "index_mentors_on_longitude"
    t.index ["nickname"], name: "index_mentors_on_nickname"
    t.index ["reset_password_token"], name: "index_mentors_on_reset_password_token", unique: true
    t.index ["user_type"], name: "index_mentors_on_user_type"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id"
    t.string "notifable_type"
    t.bigint "notifable_id"
    t.text "message"
    t.string "status"
    t.float "amount"
    t.boolean "reduce_coin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifable_type", "notifable_id"], name: "index_notifications_on_notifable_type_and_notifable_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id"
    t.string "merchant_id"
    t.string "orderable_type"
    t.bigint "orderable_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
    t.index ["orderable_type", "orderable_id"], name: "index_orders_on_orderable_type_and_orderable_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.integer "user_id"
    t.string "pictureable_type"
    t.bigint "pictureable_id"
    t.string "file_url"
    t.string "file_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pictureable_type", "pictureable_id"], name: "index_pictures_on_pictureable_type_and_pictureable_id"
    t.index ["user_id"], name: "index_pictures_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id"
    t.integer "sender_id"
    t.integer "job_id"
    t.text "comment"
    t.integer "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_reviews_on_job_id"
    t.index ["sender_id"], name: "index_reviews_on_sender_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "role_name"
    t.string "role_code"
    t.text "authorities"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_applies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "menthor_id"
    t.integer "school_partner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menthor_id"], name: "index_school_applies_on_menthor_id"
    t.index ["school_partner_id"], name: "index_school_applies_on_school_partner_id"
    t.index ["user_id"], name: "index_school_applies_on_user_id"
  end

  create_table "school_partners", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.text "full_address"
    t.string "city"
    t.integer "postcode"
    t.string "state"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscription_packages", force: :cascade do |t|
    t.integer "user_id"
    t.date "expired_date"
    t.float "amount"
    t.string "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_subscription_packages_on_merchant_id"
    t.index ["user_id"], name: "index_subscription_packages_on_user_id"
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
    t.integer "company_id"
    t.integer "role_id"
    t.float "latitude"
    t.float "longitude"
    t.string "user_type"
    t.string "access_token"
    t.string "uuid"
    t.text "skill_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_users_on_access_token"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["latitude"], name: "index_users_on_latitude"
    t.index ["longitude"], name: "index_users_on_longitude"
    t.index ["nickname"], name: "index_users_on_nickname"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["user_type"], name: "index_users_on_user_type"
  end

end
