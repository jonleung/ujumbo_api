class CreateUserPipes < ActiveRecord::Migration
  def change
    create_table :user_pipes do |t|
      t.string :action
      t.text :platform_properties_list
      t.text :product_properties_type_hash
      t.string :type

      t.string :key

      t.timestamps
    end
  end
end
