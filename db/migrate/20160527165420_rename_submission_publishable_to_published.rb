class RenameSubmissionPublishableToPublished < ActiveRecord::Migration
  def up
    rename_column :submissions, :publishable, :published

    Submission.all.each do |submission|
      # TODO FIXME This needs to be smarter (either step04 or step06)
      visibility =
        if submission.content.step04.publishability == "private"
          "private"
        else
          "published"
        end
      submission.content.update(:step04, visibility: visibility)
      submission.save!
    end
  end

  def down
    rename_column :submissions, :published, :publishable
  end
end
