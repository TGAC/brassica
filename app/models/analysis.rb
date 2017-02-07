class Analysis < ActiveRecord::Base
  enum analysis_type: %w(gwas)
  enum status: %w(idle running success failure)

  # NOTE: there is args attribute stored as json

  belongs_to :owner, class_name: "User"
  has_many :data_files, class_name: "Analysis::DataFile", dependent: :destroy

  validates :owner, :name, presence: true
  validates :name, length: { maximum: 250 }
  validates :associated_pid, numericality: { only_integer: true, allow_nil: true }
  validate :check_args

  scope :recent_first, -> { order(updated_at: :desc) }

  private

  # TODO: rename args to specification (or spec)
  def check_args
    # TODO: check args
  end
end
