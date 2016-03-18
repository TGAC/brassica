class RemovePublishedFlagFromSubmissions < ActiveRecord::Migration

  def up
    if column_exists?(:submissions, :published)
      remove_column(:submissions, :published)
    end
    if column_exists?(:submission_uploads, :published)
      remove_column(:submission_uploads, :published)
    end
  end

  def down
    unless column_exists?(:submissions, :published)
      add_column(:submissions, :published, :boolean, null: false, default:true)
    end
    unless column_exists?(:submission_uploads, :published)
      add_column(:submission_uploads, :published, :boolean, null: false, default:true)
    end
  end
end
