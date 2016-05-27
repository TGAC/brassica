class RenameSubmissionPublishableToPublished < ActiveRecord::Migration
  def change
    rename_column :submissions, :publishable, :published
  end
end
