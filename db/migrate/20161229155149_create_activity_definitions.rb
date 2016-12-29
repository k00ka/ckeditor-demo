class CreateActivityDefinitions < ActiveRecord::Migration
  def change
    create_table :activity_definitions do |t|
      t.text :html_blob

      t.timestamps
    end
  end
end
