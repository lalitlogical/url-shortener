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

ActiveRecord::Schema[8.0].define(version: 2025_06_18_053341) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clicks", force: :cascade do |t|
    t.bigint "shortened_url_id", null: false
    t.string "ip_address"
    t.string "referer"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shortened_url_id"], name: "index_clicks_on_shortened_url_id"
  end

  create_table "shortened_urls", force: :cascade do |t|
    t.string "original_url", null: false
    t.string "short_code", null: false
    t.boolean "is_active", default: true
    t.datetime "expiration"
    t.integer "click_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "passcode_digest"
    t.index ["short_code"], name: "index_shortened_urls_on_short_code", unique: true
  end

  add_foreign_key "clicks", "shortened_urls"
end
