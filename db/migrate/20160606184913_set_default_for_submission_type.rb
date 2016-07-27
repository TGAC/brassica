class SetDefaultForSubmissionType < ActiveRecord::Migration
  def up
    change_column_default :submissions, :submission_type, 0
  end

  def down
    change_column_default :submissions, :submission_type, nil
  end
end
