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

ActiveRecord::Schema.define(version: 20161213225130) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "datasets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deposits", force: :cascade do |t|
    t.string   "uuid"
    t.string   "title"
    t.string   "pure_uuid"
    t.string   "readme"
    t.string   "available"
    t.string   "embargo_end"
    t.string   "access"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "dipuuid"
    t.string   "status"
    t.string   "release"
    t.string   "retention_policy"
    t.string   "notes"
  end

  create_table "reingests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

  create_table "sipity_agents", force: :cascade do |t|
    t.string   "proxy_for_id",   null: false
    t.string   "proxy_for_type", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "sipity_agents", ["proxy_for_id", "proxy_for_type"], name: "sipity_agents_proxy_for", unique: true

  create_table "sipity_comments", force: :cascade do |t|
    t.integer  "entity_id",  null: false
    t.integer  "agent_id",   null: false
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sipity_comments", ["agent_id"], name: "index_sipity_comments_on_agent_id"
  add_index "sipity_comments", ["created_at"], name: "index_sipity_comments_on_created_at"
  add_index "sipity_comments", ["entity_id"], name: "index_sipity_comments_on_entity_id"

  create_table "sipity_entities", force: :cascade do |t|
    t.string   "proxy_for_global_id", null: false
    t.integer  "workflow_id",         null: false
    t.integer  "workflow_state_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "sipity_entities", ["proxy_for_global_id"], name: "sipity_entities_proxy_for_global_id", unique: true
  add_index "sipity_entities", ["workflow_id"], name: "index_sipity_entities_on_workflow_id"
  add_index "sipity_entities", ["workflow_state_id"], name: "index_sipity_entities_on_workflow_state_id"

  create_table "sipity_entity_specific_responsibilities", force: :cascade do |t|
    t.integer  "workflow_role_id", null: false
    t.string   "entity_id",        null: false
    t.integer  "agent_id",         null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "sipity_entity_specific_responsibilities", ["agent_id"], name: "sipity_entity_specific_responsibilities_agent"
  add_index "sipity_entity_specific_responsibilities", ["entity_id"], name: "sipity_entity_specific_responsibilities_entity"
  add_index "sipity_entity_specific_responsibilities", ["workflow_role_id", "entity_id", "agent_id"], name: "sipity_entity_specific_responsibilities_aggregate", unique: true
  add_index "sipity_entity_specific_responsibilities", ["workflow_role_id"], name: "sipity_entity_specific_responsibilities_role"

  create_table "sipity_notifiable_contexts", force: :cascade do |t|
    t.integer  "scope_for_notification_id",   null: false
    t.string   "scope_for_notification_type", null: false
    t.string   "reason_for_notification",     null: false
    t.integer  "notification_id",             null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "sipity_notifiable_contexts", ["notification_id"], name: "sipity_notifiable_contexts_notification_id"
  add_index "sipity_notifiable_contexts", ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification", "notification_id"], name: "sipity_notifiable_contexts_concern_surrogate", unique: true
  add_index "sipity_notifiable_contexts", ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification"], name: "sipity_notifiable_contexts_concern_context"
  add_index "sipity_notifiable_contexts", ["scope_for_notification_id", "scope_for_notification_type"], name: "sipity_notifiable_contexts_concern"

  create_table "sipity_notification_recipients", force: :cascade do |t|
    t.integer  "notification_id",    null: false
    t.integer  "role_id",            null: false
    t.string   "recipient_strategy", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "sipity_notification_recipients", ["notification_id", "role_id", "recipient_strategy"], name: "sipity_notifications_recipients_surrogate"
  add_index "sipity_notification_recipients", ["notification_id"], name: "sipity_notification_recipients_notification"
  add_index "sipity_notification_recipients", ["recipient_strategy"], name: "sipity_notification_recipients_recipient_strategy"
  add_index "sipity_notification_recipients", ["role_id"], name: "sipity_notification_recipients_role"

  create_table "sipity_notifications", force: :cascade do |t|
    t.string   "name",              null: false
    t.string   "notification_type", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "sipity_notifications", ["name"], name: "index_sipity_notifications_on_name", unique: true
  add_index "sipity_notifications", ["notification_type"], name: "index_sipity_notifications_on_notification_type"

  create_table "sipity_roles", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sipity_roles", ["name"], name: "index_sipity_roles_on_name", unique: true

  create_table "sipity_workflow_actions", force: :cascade do |t|
    t.integer  "workflow_id",                 null: false
    t.integer  "resulting_workflow_state_id"
    t.string   "name",                        null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "sipity_workflow_actions", ["resulting_workflow_state_id"], name: "sipity_workflow_actions_resulting_workflow_state"
  add_index "sipity_workflow_actions", ["workflow_id", "name"], name: "sipity_workflow_actions_aggregate", unique: true
  add_index "sipity_workflow_actions", ["workflow_id"], name: "sipity_workflow_actions_workflow"

  create_table "sipity_workflow_responsibilities", force: :cascade do |t|
    t.integer  "agent_id",         null: false
    t.integer  "workflow_role_id", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "sipity_workflow_responsibilities", ["agent_id", "workflow_role_id"], name: "sipity_workflow_responsibilities_aggregate", unique: true

  create_table "sipity_workflow_roles", force: :cascade do |t|
    t.integer  "workflow_id", null: false
    t.integer  "role_id",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sipity_workflow_roles", ["workflow_id", "role_id"], name: "sipity_workflow_roles_aggregate", unique: true

  create_table "sipity_workflow_state_action_permissions", force: :cascade do |t|
    t.integer  "workflow_role_id",         null: false
    t.integer  "workflow_state_action_id", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "sipity_workflow_state_action_permissions", ["workflow_role_id", "workflow_state_action_id"], name: "sipity_workflow_state_action_permissions_aggregate", unique: true

  create_table "sipity_workflow_state_actions", force: :cascade do |t|
    t.integer  "originating_workflow_state_id", null: false
    t.integer  "workflow_action_id",            null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "sipity_workflow_state_actions", ["originating_workflow_state_id", "workflow_action_id"], name: "sipity_workflow_state_actions_aggregate", unique: true

  create_table "sipity_workflow_states", force: :cascade do |t|
    t.integer  "workflow_id", null: false
    t.string   "name",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sipity_workflow_states", ["name"], name: "index_sipity_workflow_states_on_name"
  add_index "sipity_workflow_states", ["workflow_id", "name"], name: "sipity_type_state_aggregate", unique: true

  create_table "sipity_workflows", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "label"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sipity_workflows", ["name"], name: "index_sipity_workflows_on_name", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "guest",                  default: false
    t.string   "provider"
    t.string   "uid"
    t.boolean  "admin"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
