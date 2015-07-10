class CreateSubmissionUploads < ActiveRecord::Migration
  def change
    create_table :submission_uploads do |t|
      t.references :submission, null: false, index: true
      t.integer :upload_type, null: false
      t.timestamps null: false
    end
    add_attachment :submission_uploads, :file
    add_foreign_key :submission_uploads, :submissions, on_update: :cascade,
                                                       on_delete: :restrict
  end
end
