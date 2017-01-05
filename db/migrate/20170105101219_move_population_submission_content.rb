class MovePopulationSubmissionContent < ActiveRecord::Migration
  def up
    Rake::Task['update_data:move_population_submission_content'].invoke
  end

  def down
  end
end
