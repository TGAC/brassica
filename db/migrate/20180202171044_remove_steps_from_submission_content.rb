class RemoveStepsFromSubmissionContent < ActiveRecord::Migration
  def up
    Submission.all.each do |submission|
      submission.update!(content: submission.content.to_h.values.reduce({}) { |sum, step| sum.merge(step) })
      submission.content.update(submission.step, {})
      submission.save!
    end
  end

  def down
    fail ActiveRecordd::IrreversibleMigration
  end
end
