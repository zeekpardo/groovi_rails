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

ActiveRecord::Schema[8.0].define(version: 2025_08_18_185518) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_invitations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "invited_by_id"
    t.string "token", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.jsonb "roles", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "campus_id", null: false
    t.index ["account_id", "email"], name: "index_account_invitations_on_account_id_and_email", unique: true
    t.index ["campus_id"], name: "index_account_invitations_on_campus_id"
    t.index ["invited_by_id"], name: "index_account_invitations_on_invited_by_id"
    t.index ["token"], name: "index_account_invitations_on_token", unique: true
  end

  create_table "account_users", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "user_id"
    t.jsonb "roles", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "user_id"], name: "index_account_users_on_account_id_and_user_id", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "owner_id"
    t.boolean "personal", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "extra_billing_info"
    t.string "domain"
    t.string "subdomain"
    t.string "billing_email"
    t.integer "account_users_count", default: 0
    t.json "settings"
    t.index ["owner_id"], name: "index_accounts_on_owner_id"
  end

  create_table "action_text_embeds", force: :cascade do |t|
    t.string "url"
    t.jsonb "fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.string "kind"
    t.string "title"
    t.datetime "published_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token"
    t.string "name"
    t.jsonb "metadata"
    t.boolean "transient", default: false
    t.datetime "last_used_at", precision: nil
    t.datetime "expires_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "campus", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "phone"
    t.string "email"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country", default: "United States"
    t.string "time_zone", default: "America/New_York"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "unique_key"
    t.index ["account_id", "active"], name: "index_campus_on_account_id_and_active"
    t.index ["account_id", "name"], name: "index_campus_on_account_id_and_name", unique: true
    t.index ["account_id", "unique_key"], name: "index_campus_on_account_id_and_unique_key", unique: true
    t.index ["account_id"], name: "index_campus_on_account_id"
    t.index ["city"], name: "index_campus_on_city"
    t.index ["country"], name: "index_campus_on_country"
    t.index ["latitude", "longitude"], name: "index_campus_on_latitude_and_longitude"
    t.index ["state"], name: "index_campus_on_state"
  end

  create_table "campus_staffs", force: :cascade do |t|
    t.bigint "campus_id", null: false
    t.bigint "user_id", null: false
    t.string "title"
    t.boolean "active", default: true, null: false
    t.date "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id"
    t.date "end_date"
    t.string "employment_type", default: "volunteer"
    t.boolean "system_access", default: false, null: false
    t.string "permission_level", default: "viewer"
    t.bigint "access_granted_by_id"
    t.datetime "access_granted_at", precision: nil
    t.text "access_notes"
    t.index ["access_granted_by_id"], name: "index_campus_staffs_on_access_granted_by_id"
    t.index ["active"], name: "index_campus_staffs_on_active"
    t.index ["campus_id", "user_id"], name: "index_campus_staffs_on_campus_id_and_user_id", unique: true
    t.index ["campus_id"], name: "index_campus_staffs_on_campus_id"
    t.index ["employment_type"], name: "index_campus_staffs_on_employment_type"
    t.index ["role_id"], name: "index_campus_staffs_on_role_id"
    t.index ["system_access"], name: "index_campus_staffs_on_system_access", where: "(system_access = true)"
    t.index ["user_id", "campus_id", "system_access", "active"], name: "idx_campus_staffs_system_access_lookup", where: "((system_access = true) AND (active = true))"
    t.index ["user_id"], name: "index_campus_staffs_on_user_id"
    t.check_constraint "permission_level::text = ANY (ARRAY['admin'::character varying::text, 'manager'::character varying::text, 'editor'::character varying::text, 'viewer'::character varying::text])", name: "valid_permission_level"
  end

  create_table "campus_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "campus_id", null: false
    t.boolean "campus_admin", default: false
    t.boolean "people_manager", default: false
    t.boolean "viewer", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campus_id"], name: "index_campus_users_on_campus_id"
    t.index ["user_id", "campus_id"], name: "index_campus_users_on_user_id_and_campus_id", unique: true
    t.index ["user_id"], name: "index_campus_users_on_user_id"
  end

  create_table "connected_accounts", force: :cascade do |t|
    t.bigint "owner_id"
    t.string "provider"
    t.string "uid"
    t.string "refresh_token"
    t.datetime "expires_at", precision: nil
    t.jsonb "auth"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "access_token"
    t.string "access_token_secret"
    t.string "owner_type"
    t.index ["owner_id", "owner_type"], name: "index_connected_accounts_on_owner_id_and_owner_type"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "participant_type", null: false
    t.bigint "participant_id", null: false
    t.string "title", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "last_message_at"], name: "index_conversations_on_account_id_and_last_message_at"
    t.index ["account_id", "participant_type", "participant_id"], name: "index_conversations_on_account_and_participant", unique: true
    t.index ["account_id"], name: "index_conversations_on_account_id"
    t.index ["participant_type", "participant_id"], name: "index_conversations_on_participant_type_and_participant_id"
  end

  create_table "custom_field_values", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "custom_field_id", null: false
    t.text "value"
    t.json "file_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_id"], name: "index_custom_field_values_on_custom_field_id"
    t.index ["user_id", "custom_field_id"], name: "index_custom_field_values_on_person_and_field", unique: true
    t.index ["user_id"], name: "index_custom_field_values_on_user_id"
  end

  create_table "custom_fields", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "custom_tab_id", null: false
    t.string "name", null: false
    t.string "key", null: false
    t.string "field_type", null: false
    t.json "options", default: {}
    t.text "placeholder"
    t.integer "position", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unique_key", null: false, comment: "Immutable unique key for dynamic data access (e.g., {{custom.ministry_role}})"
    t.index ["account_id", "custom_tab_id", "key"], name: "index_custom_fields_on_account_tab_key", unique: true
    t.index ["account_id"], name: "index_custom_fields_on_account_id"
    t.index ["custom_tab_id", "active"], name: "index_custom_fields_on_custom_tab_id_and_active"
    t.index ["custom_tab_id", "position"], name: "index_custom_fields_on_custom_tab_id_and_position"
    t.index ["custom_tab_id"], name: "index_custom_fields_on_custom_tab_id"
    t.index ["field_type"], name: "index_custom_fields_on_field_type"
    t.index ["unique_key"], name: "index_custom_fields_on_unique_key", unique: true
  end

  create_table "custom_tabs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "key", null: false
    t.text "description"
    t.string "icon"
    t.integer "position", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "active"], name: "index_custom_tabs_on_account_id_and_active"
    t.index ["account_id", "key"], name: "index_custom_tabs_on_account_id_and_key", unique: true
    t.index ["account_id", "position"], name: "index_custom_tabs_on_account_id_and_position"
    t.index ["account_id"], name: "index_custom_tabs_on_account_id"
  end

  create_table "flow_assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "campus_id", null: false
    t.bigint "flow_step_id", null: false
    t.bigint "assigned_by_id", null: false
    t.string "status", default: "active", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "assigned_date", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "completed_date"
    t.datetime "due_date"
    t.bigint "completed_by_id"
    t.bigint "assignee_id"
    t.index ["assigned_by_id"], name: "index_flow_assignments_on_assigned_by_id"
    t.index ["assigned_date"], name: "index_flow_assignments_on_assigned_date"
    t.index ["assignee_id", "status"], name: "index_flow_assignments_on_assignee_id_and_status"
    t.index ["assignee_id"], name: "index_flow_assignments_on_assignee_id"
    t.index ["campus_id", "status"], name: "index_flow_assignments_on_campus_id_and_status"
    t.index ["campus_id"], name: "index_flow_assignments_on_campus_id"
    t.index ["completed_by_id"], name: "index_flow_assignments_on_completed_by_id"
    t.index ["due_date"], name: "index_flow_assignments_on_due_date"
    t.index ["flow_step_id", "status"], name: "index_flow_assignments_on_flow_step_id_and_status"
    t.index ["flow_step_id"], name: "index_flow_assignments_on_flow_step_id"
    t.index ["user_id", "status"], name: "index_flow_assignments_on_user_id_and_status"
    t.index ["user_id"], name: "index_flow_assignments_on_user_id"
  end

  create_table "flow_campuses", force: :cascade do |t|
    t.bigint "flow_id", null: false
    t.bigint "campus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campus_id"], name: "index_flow_campuses_on_campus_id"
    t.index ["flow_id"], name: "index_flow_campuses_on_flow_id"
  end

  create_table "flow_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "color", default: "#3B82F6", null: false
    t.boolean "active", default: true, null: false
    t.integer "position"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_flow_categories_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_flow_categories_on_account_id_and_position"
    t.index ["account_id"], name: "index_flow_categories_on_account_id"
  end

  create_table "flow_collaborators", force: :cascade do |t|
    t.bigint "flow_id", null: false
    t.bigint "user_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flow_id", "user_id"], name: "index_flow_collaborators_on_flow_id_and_user_id", unique: true
    t.index ["flow_id"], name: "index_flow_collaborators_on_flow_id"
    t.index ["user_id"], name: "index_flow_collaborators_on_user_id"
  end

  create_table "flow_steps", force: :cascade do |t|
    t.bigint "flow_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "step_type", default: "manual_action", null: false
    t.text "instructions"
    t.integer "position", default: 1, null: false
    t.integer "due_days", default: 0
    t.text "settings"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_assignee_id"
    t.index ["default_assignee_id"], name: "index_flow_steps_on_default_assignee_id"
    t.index ["flow_id", "active"], name: "index_flow_steps_on_flow_id_and_active"
    t.index ["flow_id", "position"], name: "index_flow_steps_on_flow_id_and_position"
    t.index ["flow_id"], name: "index_flow_steps_on_flow_id"
  end

  create_table "flows", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.integer "position", default: 1, null: false
    t.text "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "flow_category_id"
    t.bigint "owner_id", null: false
    t.index ["account_id", "active"], name: "index_flows_on_account_id_and_active"
    t.index ["account_id", "position"], name: "index_flows_on_account_id_and_position"
    t.index ["account_id"], name: "index_flows_on_account_id"
    t.index ["flow_category_id"], name: "index_flows_on_flow_category_id"
    t.index ["owner_id"], name: "index_flows_on_owner_id"
  end

  create_table "household_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "household_id", null: false
    t.string "relationship_type"
    t.boolean "is_primary_household"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "relationship_type"], name: "idx_on_household_id_relationship_type_4e80ea527c"
    t.index ["household_id"], name: "index_household_memberships_on_household_id"
    t.index ["user_id", "is_primary_household"], name: "idx_on_user_id_is_primary_household", where: "(is_primary_household = true)"
    t.index ["user_id"], name: "index_household_memberships_on_user_id"
  end

  create_table "households", force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "household_phone"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_households_on_account_id"
  end

  create_table "inbound_webhooks", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "link_clicks", force: :cascade do |t|
    t.bigint "shortened_link_id", null: false
    t.inet "ip_address"
    t.string "user_agent"
    t.string "referrer"
    t.string "country"
    t.string "city"
    t.string "device_type"
    t.string "browser"
    t.jsonb "metadata", default: {}
    t.datetime "clicked_at", null: false
    t.index ["clicked_at"], name: "index_link_clicks_on_clicked_at"
    t.index ["country"], name: "index_link_clicks_on_country"
    t.index ["device_type"], name: "index_link_clicks_on_device_type"
    t.index ["shortened_link_id", "clicked_at"], name: "index_link_clicks_on_shortened_link_id_and_clicked_at"
    t.index ["shortened_link_id"], name: "index_link_clicks_on_shortened_link_id"
  end

  create_table "message_templates", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "created_by_id", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.string "channel", null: false
    t.string "subject"
    t.text "body_text", null: false
    t.text "body_html"
    t.text "description"
    t.boolean "active", default: true
    t.string "locale", default: "en"
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "key", "channel"], name: "index_message_templates_on_account_id_and_key_and_channel", unique: true
    t.index ["account_id"], name: "index_message_templates_on_account_id"
    t.index ["channel", "active"], name: "index_message_templates_on_channel_and_active"
    t.index ["created_by_id"], name: "index_message_templates_on_created_by_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "conversation_id", null: false
    t.string "sender_type"
    t.bigint "sender_id"
    t.string "channel", null: false
    t.string "direction", null: false
    t.string "to_address"
    t.string "from_address"
    t.string "subject"
    t.text "body_text", null: false
    t.text "body_html"
    t.string "status", default: "queued", null: false
    t.string "provider_message_id"
    t.string "error_code"
    t.text "error_message"
    t.jsonb "metadata", default: {}
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "failed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_messages_on_account_id"
    t.index ["channel", "status"], name: "index_messages_on_channel_and_status"
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["provider_message_id"], name: "index_messages_on_provider_message_id"
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender_type_and_sender_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.bigint "account_id"
    t.string "type"
    t.string "record_type"
    t.bigint "record_id"
    t.jsonb "params"
    t.integer "notifications_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_noticed_events_on_account_id"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.bigint "account_id"
    t.string "type"
    t.bigint "event_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_noticed_notifications_on_account_id"
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "email_opted_out_at"
    t.datetime "sms_opted_out_at"
    t.datetime "whatsapp_opted_in_at"
    t.time "quiet_hours_start"
    t.time "quiet_hours_end"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "recipient_type", "recipient_id"], name: "index_notification_prefs_on_account_and_recipient", unique: true
    t.index ["account_id"], name: "index_notification_preferences_on_account_id"
    t.index ["recipient_type", "recipient_id"], name: "idx_on_recipient_type_recipient_id_474b1f9e8d"
  end

  create_table "notification_tokens", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token", null: false
    t.string "platform", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_tokens_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type"
    t.jsonb "params"
    t.datetime "read_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "interacted_at", precision: nil
    t.index ["account_id"], name: "index_notifications_on_account_id"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient_type_and_recipient_id"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.string "processor_id", null: false
    t.integer "amount", null: false
    t.integer "amount_refunded"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "data"
    t.integer "application_fee_amount"
    t.string "currency"
    t.jsonb "metadata"
    t.integer "subscription_id"
    t.bigint "customer_id"
    t.string "stripe_account"
    t.string "type"
    t.jsonb "object"
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_customers", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor"
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_account"
    t.string "type"
    t.jsonb "object"
    t.index ["owner_type", "owner_id", "deleted_at"], name: "customer_owner_processor_index"
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id"
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor"
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.bigint "customer_id"
    t.string "processor_id"
    t.boolean "default"
    t.string "payment_method_type"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_account"
    t.string "type"
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "trial_ends_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "status"
    t.jsonb "data"
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.jsonb "metadata"
    t.bigint "customer_id"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.boolean "metered"
    t.string "pause_behavior"
    t.datetime "pause_starts_at"
    t.datetime "pause_resumes_at"
    t.string "payment_method_id"
    t.string "stripe_account"
    t.string "type"
    t.jsonb "object"
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
    t.index ["metered"], name: "index_pay_subscriptions_on_metered"
    t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.string "processor"
    t.string "event_type"
    t.jsonb "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "person_positions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "position_id", null: false
    t.integer "skill_level"
    t.integer "availability"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_times_per_month", default: 4
    t.boolean "requires_oversight", default: false
    t.boolean "can_lead_others", default: false
    t.text "notes"
    t.boolean "is_leader", default: false
    t.index ["account_id"], name: "index_person_positions_on_account_id"
    t.index ["position_id"], name: "index_person_positions_on_position_id"
    t.index ["user_id"], name: "index_person_positions_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name", null: false
    t.integer "amount", default: 0, null: false
    t.string "interval", null: false
    t.jsonb "details"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "trial_period_days", default: 0
    t.boolean "hidden"
    t.string "currency"
    t.integer "interval_count", default: 1
    t.string "description"
    t.string "unit_label"
    t.boolean "charge_per_unit"
    t.string "stripe_id"
    t.string "braintree_id"
    t.string "paddle_billing_id"
    t.string "paddle_classic_id"
    t.string "lemon_squeezy_id"
    t.string "fake_processor_id"
    t.string "contact_url"
  end

  create_table "playlist_items", force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.string "schema_type", null: false
    t.string "title", null: false
    t.text "target_value", null: false
    t.integer "position", null: false
    t.integer "click_count", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_id", "active"], name: "index_playlist_items_on_playlist_id_and_active"
    t.index ["playlist_id", "position"], name: "index_playlist_items_on_playlist_id_and_position"
    t.index ["playlist_id"], name: "index_playlist_items_on_playlist_id"
    t.index ["schema_type"], name: "index_playlist_items_on_schema_type"
  end

  create_table "playlists", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "description"
    t.string "short_code", null: false
    t.string "playlist_type", default: "sequential", null: false
    t.integer "current_position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.jsonb "settings", default: {}
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "qr_code_id", null: false
    t.index ["account_id", "created_at"], name: "index_playlists_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_playlists_on_account_id"
    t.index ["created_by_id"], name: "index_playlists_on_created_by_id"
    t.index ["playlist_type"], name: "index_playlists_on_playlist_type"
    t.index ["qr_code_id"], name: "index_playlists_on_qr_code_id", unique: true
    t.index ["short_code"], name: "index_playlists_on_short_code", unique: true
  end

  create_table "positions", force: :cascade do |t|
    t.string "title"
    t.integer "required_count"
    t.integer "minimum_age"
    t.boolean "leadership_role"
    t.bigint "team_id", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_positions_on_account_id"
    t.index ["team_id"], name: "index_positions_on_team_id"
  end

  create_table "qr_codes", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "linkable_type", null: false
    t.bigint "linkable_id", null: false
    t.string "name", null: false
    t.string "short_url", null: false
    t.jsonb "design_settings", default: {}
    t.integer "download_count", default: 0, null: false
    t.integer "scan_count", default: 0, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_qr_codes_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_qr_codes_on_account_id"
    t.index ["created_by_id"], name: "index_qr_codes_on_created_by_id"
    t.index ["linkable_type", "linkable_id"], name: "index_qr_codes_on_linkable"
    t.index ["linkable_type", "linkable_id"], name: "index_qr_codes_on_linkable_type_and_linkable_id"
    t.index ["short_url"], name: "index_qr_codes_on_short_url"
  end

  create_table "relationship_types", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "description"
    t.integer "position", null: false
    t.boolean "active", default: true
    t.boolean "is_default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_relationship_types_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_relationship_types_on_account_id_and_position", unique: true
    t.index ["account_id"], name: "index_relationship_types_on_account_id"
    t.index ["active"], name: "index_relationship_types_on_active"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "account_id", null: false
    t.boolean "active", default: true, null: false
    t.boolean "is_default", default: false, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_roles_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_roles_on_account_id_and_position"
    t.index ["account_id"], name: "index_roles_on_account_id"
  end

  create_table "shortened_links", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "short_code", null: false
    t.string "custom_slug"
    t.string "title"
    t.text "description"
    t.string "schema_type", null: false
    t.text "target_value", null: false
    t.integer "click_count", default: 0, null: false
    t.jsonb "metadata", default: {}
    t.jsonb "settings", default: {}
    t.datetime "expires_at"
    t.boolean "active", default: true, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_shortened_links_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_shortened_links_on_account_id"
    t.index ["active"], name: "index_shortened_links_on_active"
    t.index ["created_by_id"], name: "index_shortened_links_on_created_by_id"
    t.index ["custom_slug"], name: "index_shortened_links_on_custom_slug", unique: true, where: "(custom_slug IS NOT NULL)"
    t.index ["schema_type"], name: "index_shortened_links_on_schema_type"
    t.index ["short_code"], name: "index_shortened_links_on_short_code", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.bigint "account_id", null: false
    t.integer "tags_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_tags_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_tags_on_account_id"
  end

  create_table "team_campuses", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "campus_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campus_id"], name: "index_team_campuses_on_campus_id"
    t.index ["team_id", "campus_id"], name: "index_team_campuses_on_team_id_and_campus_id", unique: true
    t.index ["team_id"], name: "index_team_campuses_on_team_id"
  end

  create_table "team_leaders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.bigint "account_id", null: false
    t.integer "skill_level", default: 0
    t.integer "availability", default: 0
    t.integer "max_times_per_month", default: 4
    t.boolean "requires_oversight", default: false
    t.boolean "can_lead_others", default: false
    t.boolean "is_leader", default: true
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_team_leaders_on_account_id"
    t.index ["team_id"], name: "index_team_leaders_on_team_id"
    t.index ["user_id", "team_id"], name: "index_team_leaders_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_team_leaders_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
    t.index ["account_id"], name: "index_teams_on_account_id"
  end

  create_table "user_staff_relationships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "staff_user_id", null: false
    t.bigint "campus_id", null: false
    t.bigint "relationship_type_id", null: false
    t.boolean "active", default: true, null: false
    t.date "start_date"
    t.date "end_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_user_staff_relationships_on_active"
    t.index ["campus_id"], name: "index_user_staff_relationships_on_campus_id"
    t.index ["relationship_type_id"], name: "index_user_staff_relationships_on_relationship_type_id"
    t.index ["staff_user_id"], name: "index_user_staff_relationships_on_staff_user_id"
    t.index ["user_id", "staff_user_id", "relationship_type_id", "campus_id"], name: "idx_user_staff_rel_unique", unique: true
    t.index ["user_id"], name: "index_user_staff_relationships_on_user_id"
  end

  create_table "user_tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tag_id", null: false
    t.string "created_by_type", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_type", "created_by_id"], name: "index_person_tags_on_created_by"
    t.index ["tag_id"], name: "index_user_tags_on_tag_id"
    t.index ["user_id", "tag_id"], name: "index_user_tags_on_user_id_and_tag_id", unique: true
    t.index ["user_id"], name: "index_user_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.string "time_zone"
    t.datetime "accepted_terms_at", precision: nil
    t.datetime "accepted_privacy_at", precision: nil
    t.datetime "announcements_read_at", precision: nil
    t.boolean "admin"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "preferred_language"
    t.boolean "otp_required_for_login"
    t.string "otp_secret"
    t.integer "last_otp_timestep"
    t.text "otp_backup_codes"
    t.jsonb "preferences"
    t.virtual "name", type: :string, as: "(((first_name)::text || ' '::text) || (COALESCE(last_name, ''::character varying))::text)", stored: true
    t.integer "max_services_per_month", default: 4
    t.integer "preferred_frequency", default: 0
    t.text "availability_notes"
    t.string "phone"
    t.boolean "profile_only", default: false, null: false
    t.string "contact_email"
    t.string "given_name"
    t.string "middle_name"
    t.string "nickname"
    t.string "name_prefix"
    t.string "name_suffix"
    t.date "birthdate"
    t.date "anniversary"
    t.string "gender"
    t.boolean "child", default: false
    t.integer "grade"
    t.string "school_name"
    t.string "status", default: "Active"
    t.string "inactive_reason"
    t.date "inactive_date"
    t.string "marital_status", default: "Single"
    t.string "membership_type"
    t.string "barcode"
    t.text "medical_notes"
    t.boolean "background_check_cleared", default: false
    t.date "background_check_completed"
    t.date "background_check_expires"
    t.text "background_check_notes"
    t.bigint "campus_id"
    t.index ["barcode"], name: "index_users_on_barcode", unique: true, where: "(barcode IS NOT NULL)"
    t.index ["campus_id"], name: "index_users_on_campus_id"
    t.index ["contact_email"], name: "index_users_on_contact_email", unique: true, where: "((contact_email IS NOT NULL) AND ((contact_email)::text <> ''::text))"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["last_name", "first_name"], name: "index_users_on_last_name_and_first_name"
    t.index ["profile_only"], name: "index_users_on_profile_only"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "account_invitations", "accounts"
  add_foreign_key "account_invitations", "campus", column: "campus_id"
  add_foreign_key "account_invitations", "users", column: "invited_by_id"
  add_foreign_key "account_users", "accounts"
  add_foreign_key "account_users", "users"
  add_foreign_key "accounts", "users", column: "owner_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "campus", "accounts"
  add_foreign_key "campus_staffs", "campus", column: "campus_id"
  add_foreign_key "campus_staffs", "roles"
  add_foreign_key "campus_staffs", "users"
  add_foreign_key "campus_staffs", "users", column: "access_granted_by_id"
  add_foreign_key "campus_users", "campus", column: "campus_id"
  add_foreign_key "campus_users", "users"
  add_foreign_key "conversations", "accounts"
  add_foreign_key "custom_field_values", "custom_fields"
  add_foreign_key "custom_field_values", "users"
  add_foreign_key "custom_fields", "accounts"
  add_foreign_key "custom_fields", "custom_tabs"
  add_foreign_key "custom_tabs", "accounts"
  add_foreign_key "flow_assignments", "campus", column: "campus_id"
  add_foreign_key "flow_assignments", "flow_steps"
  add_foreign_key "flow_assignments", "users"
  add_foreign_key "flow_assignments", "users", column: "assigned_by_id"
  add_foreign_key "flow_assignments", "users", column: "assignee_id"
  add_foreign_key "flow_assignments", "users", column: "completed_by_id"
  add_foreign_key "flow_campuses", "campus", column: "campus_id"
  add_foreign_key "flow_campuses", "flows"
  add_foreign_key "flow_categories", "accounts"
  add_foreign_key "flow_collaborators", "flows"
  add_foreign_key "flow_collaborators", "users"
  add_foreign_key "flow_steps", "flows"
  add_foreign_key "flow_steps", "users", column: "default_assignee_id"
  add_foreign_key "flows", "accounts"
  add_foreign_key "flows", "flow_categories"
  add_foreign_key "flows", "users", column: "owner_id"
  add_foreign_key "household_memberships", "households"
  add_foreign_key "household_memberships", "users"
  add_foreign_key "households", "accounts"
  add_foreign_key "link_clicks", "shortened_links"
  add_foreign_key "message_templates", "accounts"
  add_foreign_key "message_templates", "users", column: "created_by_id"
  add_foreign_key "messages", "accounts"
  add_foreign_key "messages", "conversations"
  add_foreign_key "notification_preferences", "accounts"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
  add_foreign_key "person_positions", "accounts"
  add_foreign_key "person_positions", "positions"
  add_foreign_key "person_positions", "users"
  add_foreign_key "playlist_items", "playlists"
  add_foreign_key "playlists", "accounts"
  add_foreign_key "playlists", "qr_codes"
  add_foreign_key "playlists", "users", column: "created_by_id"
  add_foreign_key "positions", "accounts"
  add_foreign_key "positions", "teams"
  add_foreign_key "qr_codes", "accounts"
  add_foreign_key "qr_codes", "users", column: "created_by_id"
  add_foreign_key "relationship_types", "accounts"
  add_foreign_key "roles", "accounts"
  add_foreign_key "shortened_links", "accounts"
  add_foreign_key "shortened_links", "users", column: "created_by_id"
  add_foreign_key "tags", "accounts"
  add_foreign_key "team_campuses", "campus", column: "campus_id"
  add_foreign_key "team_campuses", "teams"
  add_foreign_key "team_leaders", "accounts"
  add_foreign_key "team_leaders", "teams"
  add_foreign_key "team_leaders", "users"
  add_foreign_key "teams", "accounts"
  add_foreign_key "user_staff_relationships", "campus", column: "campus_id"
  add_foreign_key "user_staff_relationships", "relationship_types"
  add_foreign_key "user_staff_relationships", "users"
  add_foreign_key "user_staff_relationships", "users", column: "staff_user_id"
  add_foreign_key "user_tags", "tags"
  add_foreign_key "user_tags", "users"
  add_foreign_key "users", "campus", column: "campus_id"
end
