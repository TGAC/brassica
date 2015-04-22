class AddSubmittedObjectIdToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :submitted_object_id, :integer
  end
end
