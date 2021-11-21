# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140429020651) do

  create_table "jail_cells", force: true do |t|
    t.integer  "user_id"
    t.string   "screen_name", limit: 80
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "tribes", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.text     "twitter_users"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tweet_styles", force: true do |t|
    t.integer  "user_id"
    t.string   "zone",              limit: 20, default: "DEMOCRACY"
    t.integer  "tweets_per_person",            default: 2
    t.boolean  "is_show_picture",              default: true
    t.boolean  "is_show_time",                 default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",              default: false
    t.integer  "status"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
