class CreateTemplatePipes < ActiveRecord::Migration
  def change
    create_table :template_pipes do |t|
      t.text :text
      t.text :variable_regex

      t.timestamps
    end
  end
end
