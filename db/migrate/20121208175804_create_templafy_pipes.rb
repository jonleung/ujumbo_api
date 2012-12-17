class CreateTemplafyPipes < ActiveRecord::Migration
  def change
    create_table :templafy_pipes do |t|
      t.text :text
      t.text :variable_regex
      t.text :variables_hash

      t.string :key

      t.timestamps
    end
  end
end
