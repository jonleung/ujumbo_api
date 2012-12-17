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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121208175804) do

  create_table "pipelines", :force => true do |t|
    t.string   "name"
    t.integer  "product_id"
    t.text     "pipes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "templafy_pipes", :force => true do |t|
    t.text     "text"
    t.text     "variable_regex"
    t.text     "variables_hash"
    t.string   "key"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "triggers", :force => true do |t|
    t.integer  "product_id"
    t.string   "channel"
    t.text     "properties"
    t.string   "triggered_class"
    t.integer  "triggered_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "user_pipes", :force => true do |t|
    t.string   "action"
    t.text     "platform_properties_keys"
    t.text     "product_properties_type_hash"
    t.string   "type"
    t.string   "key"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "product_id"
    t.string   "email"
    t.string   "phone"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "product_properties"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

end
