class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|      
      t.integer :product_id
      t.string :channel
      t.text :properties

      t.string :triggered_class
      t.integer :triggered_id

      t.timestamps
    end
  end
end
