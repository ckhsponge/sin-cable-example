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

ActiveRecord::Schema[8.1].define(version: 2026_01_15_220250) do
  create_table "websocket_connections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "connection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["connection_id"], name: "index_websocket_connections_on_connection_id", unique: true, using: :btree_index
  end

  create_table "websocket_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "connection_id", null: false
    t.datetime "created_at", null: false
    t.string "path", null: false
    t.datetime "updated_at", null: false
    t.index ["connection_id"], name: "index_websocket_subscriptions_on_connection_id", using: :btree_index
    t.index ["path", "connection_id"], name: "index_websocket_subscriptions_on_path_and_connection_id", unique: true, using: :btree_index
  end
end
