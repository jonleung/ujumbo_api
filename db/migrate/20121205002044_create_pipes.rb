# Use http://blog.thirst.co/post/14885390861/rails-single-table-inheritance

class CreatePipes < ActiveRecord::Migration
  def change
    create_table :pipes do |t|
      t.text :type
      t.text :settings

      t.timestamps
    end
  end
end
