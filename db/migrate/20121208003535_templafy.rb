# Use http://blog.thirst.co/post/14885390861/rails-single-table-inheritance

class CreateTemplafy < ActiveRecord::Migration
  def change
    create_table :pipes do |t|
      t.text :text
      t.text :variable_regex
      t.text :variables_hash
      t.string :key

      t.timestamps
    end
  end
end
