class CreatePipelines < ActiveRecord::Migration
  def change
    create_table :pipelines do |t|
      t.string :name
      t.integer :product_id
      t.text :pipes

      t.timestamps
    end
  end
end
