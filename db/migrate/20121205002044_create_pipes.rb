class CreatePipes < ActiveRecord::Migration
  def change
    create_table :pipes do |t|
      t.text :type

      t.timestamps
    end
  end
end
