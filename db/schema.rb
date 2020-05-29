# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_28_124219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "state"
    t.string "city"
    t.integer "pincode"
    t.string "country"
    t.boolean "default", default: false, null: false
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "home_address"
    t.string "token"
    t.index ["deleted_at"], name: "index_addresses_on_deleted_at"
    t.index ["token"], name: "index_addresses_on_token", unique: true
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "deals", force: :cascade do |t|
    t.citext "title", null: false
    t.text "description"
    t.decimal "price", precision: 8, scale: 2
    t.decimal "discount_price", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "quantity", default: 0, null: false
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "live_begin"
    t.datetime "live_end"
    t.decimal "tax"
    t.integer "sold_quantity", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["deleted_at"], name: "index_deals_on_deleted_at"
    t.index ["title"], name: "index_deals_on_title", unique: true
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 8, scale: 2
    t.decimal "deal_discount_price", precision: 8, scale: 2
    t.decimal "loyalty_discount_price", precision: 8, scale: 2
    t.decimal "taxed_price", precision: 8, scale: 2
    t.bigint "order_id", null: false
    t.bigint "deal_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "sale_price", precision: 8, scale: 2
    t.decimal "sub_total", precision: 8, scale: 2
    t.decimal "sub_tax_total", precision: 8, scale: 2
    t.index ["deal_id"], name: "index_line_items_on_deal_id"
    t.index ["deleted_at"], name: "index_line_items_on_deleted_at"
    t.index ["order_id"], name: "index_line_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "total_amount"
    t.decimal "total_tax"
    t.bigint "address_id"
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 0, null: false
    t.integer "line_items_count"
    t.datetime "placed_at"
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "transaction_id", null: false
    t.integer "state", default: 0, null: false
    t.string "method"
    t.string "category"
    t.integer "amount", null: false
    t.string "currency"
    t.bigint "order_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "stripe_response"
    t.integer "card_last_digits"
    t.integer "card_exp_year"
    t.integer "card_exp_month"
    t.string "card_brand"
    t.datetime "paid_at"
    t.datetime "refunded_at"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.citext "email", null: false
    t.string "password_digest", null: false
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "verification_token"
    t.datetime "verification_token_sent_at"
    t.datetime "verified_at"
    t.boolean "admin", default: false, null: false
    t.string "stripe_customer_id"
    t.string "authentication_token"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
    t.index ["verification_token"], name: "index_users_on_verification_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "line_items", "deals"
  add_foreign_key "line_items", "orders"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
end
