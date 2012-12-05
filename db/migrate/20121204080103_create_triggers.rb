class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.integer :product_id
      
      t.string :on
      t.string :action

      t.timestamps
    end
  end
end
