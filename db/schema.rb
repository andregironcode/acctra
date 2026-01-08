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

ActiveRecord::Schema[7.1].define(version: 2025_04_01_192100) do
  # These are extensions that must be enabled in order to support this database
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

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "buyer_id", null: false
    t.decimal "offer_price", precision: 10, scale: 2
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "inventory_id", null: false
    t.decimal "quoted_price"
    t.decimal "accepted_price"
    t.integer "quantity"
    t.string "forwarder"
    t.boolean "alert"
    t.index ["buyer_id"], name: "index_bids_on_buyer_id"
    t.index ["inventory_id"], name: "index_bids_on_inventory_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "inventory_id", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["inventory_id"], name: "index_cart_items_on_inventory_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "buyer_id", null: false
    t.string "status", default: "open"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_carts_on_buyer_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "brand_id", null: false
    t.bigint "device_id", null: false
    t.index ["brand_id"], name: "index_categories_on_brand_id"
    t.index ["device_id"], name: "index_categories_on_device_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "brand_id", null: false
    t.index ["brand_id"], name: "index_devices_on_brand_id"
  end

  create_table "forwarders", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_forwarders_on_active"
    t.index ["name"], name: "index_forwarders_on_name", unique: true
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "seller_id", null: false
    t.bigint "product_id", null: false
    t.integer "stock_quantity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price"
    t.integer "rank"
    t.index ["product_id"], name: "index_inventories_on_product_id"
    t.index ["seller_id"], name: "index_inventories_on_seller_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.string "email"
    t.string "role"
    t.string "token"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "message"
    t.string "notification_type"
    t.string "status", default: "unread"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "inventory_id", null: false
    t.index ["inventory_id"], name: "index_order_items_on_inventory_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "order_product_details", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "sku"
    t.string "imei"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_product_details_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "buyer_id", null: false
    t.string "status", default: "new"
    t.decimal "total_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_approve", default: false
    t.boolean "was_bid", default: false
    t.string "forwarder"
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
  end

  create_table "pre_order_inspections", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.datetime "inspection_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_pre_order_inspections_on_order_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "sku"
    t.text "description"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id", null: false
    t.string "variant"
    t.integer "brand_id"
    t.integer "device_id"
    t.string "country"
    t.string "model_number"
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "buyer"
    t.integer "invited_by"
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.string "address"
    t.string "license_number"
    t.string "website"
    t.string "approval_status", default: "pending"
    t.boolean "suspended", default: false
    t.string "country_code"
    t.string "phone_number"
    t.string "otp"
    t.datetime "otp_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bids", "inventories"
  add_foreign_key "bids", "users", column: "buyer_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "inventories"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users", column: "buyer_id"
  add_foreign_key "categories", "brands"
  add_foreign_key "categories", "devices"
  add_foreign_key "devices", "brands"
  add_foreign_key "inventories", "products"
  add_foreign_key "inventories", "users", column: "seller_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "order_items", "inventories"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_product_details", "orders"
  add_foreign_key "orders", "users", column: "buyer_id"
  add_foreign_key "pre_order_inspections", "orders"
  add_foreign_key "products", "categories"
end
