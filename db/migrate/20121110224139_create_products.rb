class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :subdomain

      t.timestamps
    end
  end
end
