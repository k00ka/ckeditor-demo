class RenameResultsToResponsesInActivity < ActiveRecord::Migration
  def up
    rename_column :activities, :results, :responses
  end

  def down
    rename_column :activities, :responses, :results
  end
end
