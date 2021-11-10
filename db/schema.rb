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

ActiveRecord::Schema.define(version: 2021_11_08_135909) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "operators", force: :cascade do |t|
    t.bigint "vertex_robot_id"
    t.string "vertex_gid"
    t.string "webhook_url"
    t.json "entries"
    t.json "vertex"
    t.json "journey_user"
    t.string "journey_sn"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["vertex_robot_id"], name: "index_operators_on_vertex_robot_id"
  end

  create_table "vertex_robots", force: :cascade do |t|
    t.string "vertex_gid"
    t.string "webhook_secret"
    t.json "external_settings"
    t.json "vertices_attributes"
    t.json "fields_attributes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
