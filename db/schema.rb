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

ActiveRecord::Schema[8.1].define(version: 2026_06_19_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index [ "record_type", "record_id", "name" ], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index [ "blob_id" ], name: "index_active_storage_attachments_on_blob_id"
    t.index [ "metadata" ], name: "index_active_storage_attachments_on_metadata", using: :gin
    t.index [ "record_type", "record_id", "name", "blob_id" ], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index [ "key" ], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index [ "blob_id", "variation_digest" ], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignments", force: :cascade do |t|
    t.string "composition"
    t.integer "composition_id"
    t.datetime "created_at", null: false
    t.string "project_name"
    t.bigint "project_type_id"
    t.string "student"
    t.integer "student_age"
    t.integer "student_id"
    t.string "summary_video_url"
    t.string "teacher"
    t.integer "teacher_id"
    t.datetime "updated_at", null: false
    t.index [ "project_type_id" ], name: "index_assignments_on_project_type_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "bookmarkable_id", null: false
    t.string "bookmarkable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index [ "bookmarkable_type", "bookmarkable_id" ], name: "index_bookmarks_on_bookmarkable"
    t.index [ "user_id" ], name: "index_bookmarks_on_user_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "lesson_id", null: false
    t.string "name"
    t.integer "start_time"
    t.integer "stop_time"
    t.datetime "updated_at", null: false
    t.index [ "lesson_id", "start_time" ], name: "index_chapters_on_lesson_id_and_start_time"
    t.index [ "lesson_id" ], name: "index_chapters_on_lesson_id"
  end

  create_table "chapters_tutorials", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.datetime "created_at", null: false
    t.integer "sort"
    t.bigint "tutorial_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "chapter_id" ], name: "index_chapters_tutorials_on_chapter_id"
    t.index [ "tutorial_id" ], name: "index_chapters_tutorials_on_tutorial_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "admin_id"
    t.integer "annotation_id"
    t.string "annotation_type"
    t.datetime "created_at", null: false
    t.datetime "unpublished_date"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "compositions", force: :cascade do |t|
    t.string "composer"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "journal_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.bigint "journal_id", null: false
    t.string "name"
    t.integer "sort", default: 1000
    t.datetime "updated_at", null: false
    t.integer "video_end_time"
    t.integer "video_start_time"
    t.index [ "journal_id" ], name: "index_journal_entries_on_journal_id"
  end

  create_table "journals", force: :cascade do |t|
    t.bigint "composition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index [ "composition_id" ], name: "index_journals_on_composition_id"
    t.index [ "user_id" ], name: "index_journals_on_user_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "assignment_id"
    t.datetime "created_at", null: false
    t.date "date"
    t.boolean "description_copyrighted"
    t.string "description_purchase_url"
    t.string "name"
    t.integer "sort", default: 1000
    t.integer "teacher_id"
    t.datetime "updated_at", null: false
    t.integer "video_end_time"
    t.integer "video_start_time"
    t.string "video_url"
  end

  create_table "lessons_skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lesson_id"
    t.integer "skill_id"
    t.datetime "updated_at", null: false
  end

  create_table "likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "likeable_id", null: false
    t.string "likeable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index [ "likeable_type", "likeable_id" ], name: "index_likes_on_likeable"
    t.index [ "user_id" ], name: "index_likes_on_user_id"
  end

  create_table "project_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "sheet_musics", force: :cascade do |t|
    t.integer "composition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skill_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "skill_category_id"
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.integer "age_started_piano"
    t.integer "assignments_count", default: 0, null: false
    t.integer "avatar_crop_height"
    t.integer "avatar_crop_width"
    t.integer "avatar_crop_x"
    t.integer "avatar_crop_y"
    t.datetime "created_at", null: false
    t.integer "lessons_count", default: 0, null: false
    t.string "name"
    t.boolean "show_on_contributors", default: true, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "year_of_birth"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "subscribable_id"
    t.string "subscribable_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index [ "subscribable_type", "subscribable_id" ], name: "index_subscriptions_on_subscribable_type_and_subscribable_id"
    t.index [ "user_id" ], name: "index_subscriptions_on_user_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.integer "assignments_count", default: 0, null: false
    t.integer "avatar_crop_height"
    t.integer "avatar_crop_width"
    t.integer "avatar_crop_x"
    t.integer "avatar_crop_y"
    t.string "city"
    t.datetime "created_at", null: false
    t.integer "journals_count", default: 0, null: false
    t.string "name"
    t.boolean "show_on_contributors", default: true, null: false
    t.integer "tutorials_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "tutorials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "skill_category_id"
    t.integer "sort"
    t.bigint "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "skill_category_id" ], name: "index_tutorials_on_skill_category_id"
    t.index [ "teacher_id" ], name: "index_tutorials_on_teacher_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "avatar_crop_height"
    t.integer "avatar_crop_width"
    t.integer "avatar_crop_x"
    t.integer "avatar_crop_y"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.boolean "is_employee", default: false, null: false
    t.datetime "locked_at"
    t.datetime "magic_link_sent_at"
    t.string "magic_link_token"
    t.string "name"
    t.string "picture_url"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index [ "email" ], name: "index_users_on_email", unique: true
    t.index [ "magic_link_token" ], name: "index_users_on_magic_link_token", unique: true
    t.index [ "reset_password_token" ], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignments", "project_types"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "chapters", "lessons"
  add_foreign_key "chapters_tutorials", "chapters"
  add_foreign_key "chapters_tutorials", "tutorials"
  add_foreign_key "journal_entries", "journals"
  add_foreign_key "journals", "compositions"
  add_foreign_key "journals", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "tutorials", "skill_categories"
  add_foreign_key "tutorials", "teachers"
end
