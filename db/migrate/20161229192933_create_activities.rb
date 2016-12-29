class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :activity_definition
      t.text :results

      t.timestamps
    end
    add_index :activities, :activity_definition_id
  end
end
