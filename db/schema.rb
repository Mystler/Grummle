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

ActiveRecord::Schema.define(version: 20150121174707) do

  create_table "authorizations", force: :cascade do |t|
    t.string  "provider"
    t.string  "uid"
    t.integer "user_id"
  end

  add_index "authorizations", ["provider", "uid"], name: "index_authorizations_on_provider_and_uid"
  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id"

  create_table "notes", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "public"
    t.string   "permalink",  limit: 255
  end

  add_index "notes", ["permalink"], name: "index_notes_on_permalink"
  add_index "notes", ["user_id"], name: "index_notes_on_user_id"

  create_table "shares", force: :cascade do |t|
    t.integer "note_id"
    t.integer "user_id"
  end

  add_index "shares", ["note_id"], name: "index_shares_on_note_id"
  add_index "shares", ["user_id"], name: "index_shares_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "username",           limit: 255
    t.string   "email",              limit: 255
    t.string   "password_digest",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_token",         limit: 255
    t.datetime "auth_token_updated"
    t.boolean  "activated"
    t.string   "update_token"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token"
  add_index "users", ["update_token"], name: "index_users_on_update_token"
  add_index "users", ["username"], name: "index_users_on_username"

end
