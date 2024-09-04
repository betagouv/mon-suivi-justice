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

ActiveRecord::Schema[7.1].define(version: 2024_09_04_134013) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "checksum"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_agendas_on_discarded_at"
    t.index ["place_id"], name: "index_agendas_on_place_id"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "appointment_extra_fields", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "extra_field_id", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_extra_fields_on_appointment_id"
    t.index ["extra_field_id"], name: "index_appointment_extra_fields_on_extra_field_id"
  end

  create_table "appointment_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "share_address_to_convict", default: true, null: false
  end

  create_table "appointment_types_extra_fields", id: false, force: :cascade do |t|
    t.bigint "appointment_type_id", null: false
    t.bigint "extra_field_id", null: false
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "convict_id", null: false
    t.bigint "slot_id", null: false
    t.string "state"
    t.integer "origin_department"
    t.string "prosecutor_number"
    t.bigint "user_id"
    t.boolean "case_prepared", default: false, null: false
    t.bigint "inviter_user_id"
    t.bigint "creating_organization_id"
    t.index ["convict_id"], name: "index_appointments_on_convict_id"
    t.index ["creating_organization_id"], name: "index_appointments_on_creating_organization_id"
    t.index ["slot_id"], name: "index_appointments_on_slot_id"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name", null: false
    t.string "zipcode", null: false
    t.string "code_insee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city_id"
    t.bigint "srj_spip_id"
    t.bigint "srj_tj_id"
    t.index ["city_id"], name: "index_cities_on_city_id"
    t.index ["name"], name: "index_cities_on_name"
    t.index ["srj_spip_id"], name: "index_cities_on_srj_spip_id"
    t.index ["srj_tj_id"], name: "index_cities_on_srj_tj_id"
    t.index ["zipcode"], name: "index_cities_on_zipcode"
  end

  create_table "convicts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "no_phone"
    t.boolean "refused_phone"
    t.string "prosecutor_number"
    t.string "appi_uuid"
    t.datetime "discarded_at"
    t.bigint "user_id"
    t.integer "invitation_to_convict_interface_count", default: 0, null: false
    t.datetime "timestamp_convict_interface_creation"
    t.datetime "last_invite_to_convict_interface"
    t.date "date_of_birth"
    t.boolean "homeless", default: false, null: false
    t.boolean "lives_abroad", default: false, null: false
    t.bigint "city_id"
    t.bigint "creating_organization_id"
    t.boolean "japat", default: false, null: false
    t.virtual "full_name", type: :string, as: "(((first_name)::text || ' '::text) || (last_name)::text)", stored: true
    t.index ["city_id"], name: "index_convicts_on_city_id"
    t.index ["creating_organization_id"], name: "index_convicts_on_creating_organization_id"
    t.index ["discarded_at"], name: "index_convicts_on_discarded_at"
    t.index ["user_id"], name: "index_convicts_on_user_id"
  end

  create_table "convicts_organizations_mappings", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "convict_id", null: false
    t.datetime "desactivated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["convict_id"], name: "index_convicts_organizations_mappings_on_convict_id"
    t.index ["organization_id", "convict_id"], name: "index_convicts_organizations_mappings_on_org_id_and_convict_id", unique: true
    t.index ["organization_id"], name: "index_convicts_organizations_mappings_on_organization_id"
  end

  create_table "divestments", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "convict_id", null: false
    t.bigint "user_id", null: false
    t.string "state"
    t.date "decision_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["convict_id", "state"], name: "index_divestments_on_convict_id_and_state", unique: true, where: "((state)::text = 'pending'::text)"
    t.index ["convict_id"], name: "index_divestments_on_convict_id"
    t.index ["organization_id"], name: "index_divestments_on_organization_id"
    t.index ["user_id"], name: "index_divestments_on_user_id"
  end

  create_table "extra_fields", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "data_type", default: "text"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scope", default: "appointment_update", null: false
    t.index ["organization_id"], name: "index_extra_fields_on_organization_id"
  end

  create_table "headquarters", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "history_items", force: :cascade do |t|
    t.integer "event", default: 0
    t.bigint "convict_id"
    t.bigint "appointment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", default: 0
    t.text "content"
    t.index ["appointment_id"], name: "index_history_items_on_appointment_id"
    t.index ["convict_id"], name: "index_history_items_on_convict_id"
  end

  create_table "monsuivijustice_commune", id: :integer, default: nil, force: :cascade do |t|
    t.integer "city_id", null: false
    t.string "postal_code", limit: 255, null: false
    t.string "names", limit: 255, null: false
    t.string "gadm_id", limit: 255, null: false
    t.integer "geoname_id", null: false
    t.string "insee_code", limit: 255, null: false
    t.string "ascii_name", limit: 255, null: false
    t.boolean "is_analyzed"
  end

  create_table "monsuivijustice_relation_commune_structure", primary_key: ["commune_id", "structure_id"], force: :cascade do |t|
    t.integer "commune_id", null: false
    t.integer "structure_id", null: false
    t.index ["commune_id"], name: "idx_57202ffd131a4f72"
    t.index ["structure_id"], name: "idx_57202ffd2534008b"
  end

  create_table "monsuivijustice_structure", id: :integer, default: nil, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "address", limit: 255, null: false
    t.string "phone", limit: 255, null: false
    t.string "type", limit: 10
  end

  create_table "notification_types", force: :cascade do |t|
    t.bigint "appointment_type_id"
    t.text "template"
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reminder_period", default: 0
    t.bigint "organization_id"
    t.boolean "is_default", default: false, null: false
    t.boolean "still_default", default: true, null: false
    t.index ["appointment_type_id"], name: "index_notification_types_on_appointment_type_id"
    t.index ["organization_id"], name: "index_notification_types_on_organization_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "appointment_id", null: false
    t.integer "role", default: 0
    t.string "template"
    t.integer "reminder_period", default: 0
    t.string "state"
    t.string "external_id"
    t.integer "failed_count", default: 0, null: false
    t.datetime "delivery_time"
    t.index ["appointment_id"], name: "index_notifications_on_appointment_id"
  end

  create_table "organization_divestments", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "divestment_id", null: false
    t.string "state"
    t.date "decision_date"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_reminder_email_at"
    t.index ["divestment_id"], name: "index_organization_divestments_on_divestment_id"
    t.index ["organization_id"], name: "index_organization_divestments_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_type", default: 0
    t.string "time_zone", default: "Europe/Paris", null: false
    t.bigint "headquarter_id"
    t.boolean "use_inter_ressort", default: false
    t.string "email"
    t.index ["headquarter_id"], name: "index_organizations_on_headquarter_id"
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "place_appointment_types", force: :cascade do |t|
    t.bigint "place_id"
    t.bigint "appointment_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_type_id"], name: "index_place_appointment_types_on_appointment_type_id"
    t.index ["place_id"], name: "index_place_appointment_types_on_place_id"
  end

  create_table "place_transferts", force: :cascade do |t|
    t.bigint "new_place_id"
    t.bigint "old_place_id"
    t.integer "status", default: 0
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["new_place_id", "old_place_id"], name: "index_place_transferts_on_new_place_id_and_old_place_id"
    t.index ["new_place_id"], name: "index_place_transferts_on_new_place_id"
    t.index ["old_place_id", "new_place_id"], name: "index_place_transferts_on_old_place_id_and_new_place_id"
    t.index ["old_place_id"], name: "index_place_transferts_on_old_place_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.string "adress"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.string "contact_email"
    t.integer "main_contact_method", default: 0, null: false
    t.string "preparation_link", default: "https://mon-suivi-justice.beta.gouv.fr/", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_places_on_discarded_at"
    t.index ["organization_id"], name: "index_places_on_organization_id"
  end

  create_table "previous_passwords", force: :cascade do |t|
    t.string "salt", null: false
    t.string "encrypted_password", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "agenda_id"
    t.datetime "discarded_at"
    t.index ["agenda_id"], name: "index_slot_types_on_agenda_id"
    t.index ["appointment_type_id"], name: "index_slot_types_on_appointment_type_id"
    t.index ["discarded_at"], name: "index_slot_types_on_discarded_at"
    t.index ["starting_time", "agenda_id", "appointment_type_id", "week_day"], name: "index_slot_types_on_starting_time_combination", unique: true
  end

  create_table "slots", force: :cascade do |t|
    t.date "date"
    t.time "starting_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "available", default: true
    t.integer "duration", default: 30
    t.integer "capacity", default: 1
    t.integer "used_capacity", default: 0
    t.bigint "appointment_type_id", null: false
    t.bigint "agenda_id", null: false
    t.bigint "slot_type_id"
    t.boolean "full", default: false
    t.index ["agenda_id"], name: "index_slots_on_agenda_id"
    t.index ["appointment_type_id"], name: "index_slots_on_appointment_type_id"
    t.index ["slot_type_id"], name: "index_slots_on_slot_type_id"
  end

  create_table "spips_tjs", id: false, force: :cascade do |t|
    t.bigint "tj_id"
    t.bigint "spip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spip_id"], name: "index_spips_tjs_on_spip_id"
    t.index ["tj_id"], name: "index_spips_tjs_on_tj_id"
  end

  create_table "srj_spips", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "structure_id"
    t.index ["organization_id"], name: "index_srj_spips_on_organization_id"
    t.index ["structure_id"], name: "index_srj_spips_on_structure_id"
  end

  create_table "srj_tjs", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "structure_id"
    t.index ["organization_id"], name: "index_srj_tjs_on_organization_id"
    t.index ["structure_id"], name: "index_srj_tjs_on_structure_id"
  end

  create_table "user_alerts", force: :cascade do |t|
    t.string "alert_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "services"
    t.string "roles"
  end

  create_table "user_user_alerts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "user_alert_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_alert_id"], name: "index_user_user_alerts_on_user_alert_id"
    t.index ["user_id", "user_alert_id"], name: "index_user_user_alerts_on_user_id_and_user_alert_id", unique: true
    t.index ["user_id"], name: "index_user_user_alerts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", null: false
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
    t.string "phone"
    t.boolean "share_email_to_convict", default: false
    t.boolean "share_phone_to_convict", default: false
    t.bigint "headquarter_id"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "security_charter_accepted_at"
    t.virtual "full_name", type: :string, as: "(((first_name)::text || ' '::text) || (last_name)::text)", stored: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["headquarter_id"], name: "index_users_on_headquarter_id"
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
    t.datetime "created_at"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agendas", "places"
  add_foreign_key "appointment_extra_fields", "appointments"
  add_foreign_key "appointment_extra_fields", "extra_fields"
  add_foreign_key "appointments", "convicts"
  add_foreign_key "appointments", "organizations", column: "creating_organization_id"
  add_foreign_key "appointments", "slots"
  add_foreign_key "appointments", "users"
  add_foreign_key "cities", "srj_spips"
  add_foreign_key "cities", "srj_tjs"
  add_foreign_key "convicts", "cities"
  add_foreign_key "convicts", "organizations", column: "creating_organization_id"
  add_foreign_key "convicts", "users"
  add_foreign_key "divestments", "convicts"
  add_foreign_key "divestments", "organizations"
  add_foreign_key "divestments", "users"
  add_foreign_key "extra_fields", "organizations"
  add_foreign_key "history_items", "appointments"
  add_foreign_key "history_items", "convicts"
  add_foreign_key "monsuivijustice_relation_commune_structure", "monsuivijustice_commune", column: "commune_id", name: "fk_57202ffd131a4f72", on_delete: :cascade
  add_foreign_key "monsuivijustice_relation_commune_structure", "monsuivijustice_structure", column: "structure_id", name: "fk_57202ffd2534008b", on_delete: :cascade
  add_foreign_key "notification_types", "appointment_types"
  add_foreign_key "notification_types", "organizations"
  add_foreign_key "notifications", "appointments"
  add_foreign_key "organization_divestments", "divestments"
  add_foreign_key "organization_divestments", "organizations"
  add_foreign_key "organizations", "headquarters"
  add_foreign_key "places", "organizations"
  add_foreign_key "previous_passwords", "users"
  add_foreign_key "slot_types", "agendas"
  add_foreign_key "slot_types", "appointment_types"
  add_foreign_key "slots", "agendas"
  add_foreign_key "slots", "appointment_types"
  add_foreign_key "slots", "slot_types"
  add_foreign_key "spips_tjs", "organizations", column: "spip_id"
  add_foreign_key "spips_tjs", "organizations", column: "tj_id"
  add_foreign_key "srj_spips", "organizations"
  add_foreign_key "srj_tjs", "organizations"
  add_foreign_key "user_user_alerts", "user_alerts"
  add_foreign_key "user_user_alerts", "users"
  add_foreign_key "users", "headquarters"
  add_foreign_key "users", "organizations"
end
