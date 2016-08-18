class Submission::Upload < ActiveRecord::Base

  enum upload_type: %i(trait_scores plant_trial_layout)
  belongs_to :submission

  has_attached_file :file, styles: ->(attachment) {
    if attachment.content_type =~ /image/
      { small: '300x300>' }
    else
      {}
    end
  }

  validates :submission, presence: true
  validates :file, attachment_presence: true, attachment_size: { less_than: 500.megabytes }
  validates :file, attachment_content_type: { content_type: %w(image/png image/gif image/jpeg) },
    if: -> { plant_trial_layout? }
  validates :file, attachment_content_type: { content_type: %w(text/csv text/plain application/vnd.ms-excel) },
    if: -> { trait_scores? }

  # NOTE, WARNING: @logs will contain user-provided data; do NOT interpret it as html
  attr_reader :logs

  def log(string)
    @logs ||= []
    @logs << string
  end

  delegate :url, to: :file, prefix: true
end
