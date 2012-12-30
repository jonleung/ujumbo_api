class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :product_id
      t.string :email
      t.string :phone
      t.string :first_name
      t.string :last_name

      t.text :product_properties

      t.timestamps
    end
  end
end
