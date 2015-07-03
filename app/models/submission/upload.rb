class Submission::Upload < ActiveRecord::Base

  enum upload_type: %i(trait_scores)
  belongs_to :submission

  has_attached_file :file

  validates :submission, presence: true
  validates :file, attachment_presence: true, attachment_size: { less_than: 500.megabytes }

  # TODO FIXME can we validate?
  do_not_validate_attachment_file_type :file

end
