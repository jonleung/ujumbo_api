class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :text
      t.string :variable_regex

      t.timestamps
    end
  end
end
