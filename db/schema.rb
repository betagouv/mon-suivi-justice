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

ActiveRecord::Schema.define(version: 2022_01_24_181845) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agendas", force: :cascade do |t|
    t.string "name"
    t.bigint "place_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["place_id"], name: "index_agendas_on_place_id"
  end

  create_table "appointment_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "convict_id", null: false
    t.bigint "slot_id", null: false
    t.string "state"
    t.integer "origin_department", default: 0
    t.index ["convict_id"], name: "index_appointments_on_convict_id"
    t.index ["slot_id"], name: "index_appointments_on_slot_id"
  end

  create_table "areas_convicts_mappings", force: :cascade do |t|
    t.string "area_type"
    t.bigint "area_id"
    t.bigint "convict_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area_type", "area_id"], name: "index_areas_convicts_mappings_on_area"
    t.index ["convict_id", "area_id", "area_type"], name: "index_areas_convicts_mappings_on_convict_and_area", unique: true
    t.index ["convict_id"], name: "index_areas_convicts_mappings_on_convict_id"
  end

  create_table "areas_organizations_mappings", force: :cascade do |t|
    t.string "area_type"
    t.bigint "area_id"
    t.bigint "organization_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area_type", "area_id"], name: "index_areas_organizations_mappings_on_area"
    t.index ["organization_id", "area_id", "area_type"], name: "index_areas_organizations_mappings_on_organization_and_area", unique: true
    t.index ["organization_id"], name: "index_areas_organizations_mappings_on_organization_id"
  end

  create_table "convicts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "no_phone"
    t.boolean "refused_phone"
    t.string "prosecutor_number"
    t.string "appi_uuid"
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_convicts_on_discarded_at"
  end

  create_table "departments", force: :cascade do |t|
    t.string "number", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
    t.index ["number"], name: "index_departments_on_number", unique: true
  end

  create_table "history_items", force: :cascade do |t|
    t.integer "event", default: 0
    t.bigint "convict_id"
    t.bigint "appointment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "category", default: 0
    t.text "content"
    t.index ["appointment_id"], name: "index_history_items_on_appointment_id"
    t.index ["convict_id"], name: "index_history_items_on_convict_id"
  end

  create_table "jurisdictions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_jurisdictions_on_name", unique: true
  end

  create_table "notification_types", force: :cascade do |t|
    t.bigint "appointment_type_id"
    t.text "template"
    t.integer "role", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "reminder_period", default: 0
    t.index ["appointment_type_id"], name: "index_notification_types_on_appointment_type_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "appointment_id", null: false
    t.integer "role", default: 0
    t.string "template"
    t.integer "reminder_period", default: 0
    t.string "state"
    t.string "external_id"
    t.index ["appointment_id"], name: "index_notifications_on_appointment_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "place_appointment_types", force: :cascade do |t|
    t.bigint "place_id"
    t.bigint "appointment_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["appointment_type_id"], name: "index_place_appointment_types_on_appointment_type_id"
    t.index ["place_id"], name: "index_place_appointment_types_on_place_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.string "adress"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "organization_id"
    t.string "contact_email"
    t.integer "main_contact_method", default: 0, null: false
    t.index ["organization_id"], name: "index_places_on_organization_id"
  end

  create_table "previous_passwords", force: :cascade do |t|
    t.string "salt", null: false
    t.string "encrypted_password", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["encrypted_password"], name: "index_previous_passwords_on_encrypted_password"
    t.index ["user_id", "created_at"], name: "index_previous_passwords_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_previous_passwords_on_user_id"
  end

  create_table "slot_types", force: :cascade do |t|
    t.integer "week_day", default: 0
    t.time "starting_time"
    t.integer "duration", default: 30
    t.integer "capacity", default: 1
    t.bigint "appointment_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "agenda_id"
    t.index ["agenda_id"], name: "index_slot_types_on_agenda_id"
    t.index ["appointment_type_id"], name: "index_slot_types_on_appointment_type_id"
  end

  create_table "slots", force: :cascade do |t|
    t.date "date"
    t.time "starting_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "available", default: true
    t.integer "duration", default: 30
    t.integer "capacity", default: 1
    t.integer "used_capacity", default: 0
    t.bigint "appointment_type_id", null: false
    t.bigint "agenda_id", null: false
    t.bigint "slot_type_id"
    t.index ["agenda_id"], name: "index_slots_on_agenda_id"
    t.index ["appointment_type_id"], name: "index_slots_on_appointment_type_id"
    t.index ["slot_type_id"], name: "index_slots_on_slot_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", default: 0
    t.string "first_name"
    t.string "last_name"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.bigint "organization_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agendas", "places"
  add_foreign_key "appointments", "convicts"
  add_foreign_key "appointments", "slots"
  add_foreign_key "areas_convicts_mappings", "convicts"
  add_foreign_key "areas_organizations_mappings", "organizations"
  add_foreign_key "history_items", "appointments"
  add_foreign_key "history_items", "convicts"
  add_foreign_key "notification_types", "appointment_types"
  add_foreign_key "notifications", "appointments"
  add_foreign_key "places", "organizations"
  add_foreign_key "previous_passwords", "users"
  add_foreign_key "slot_types", "agendas"
  add_foreign_key "slot_types", "appointment_types"
  add_foreign_key "slots", "agendas"
  add_foreign_key "slots", "appointment_types"
  add_foreign_key "slots", "slot_types"
  add_foreign_key "users", "organizations"
end
