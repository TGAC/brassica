class Analysis < ActiveRecord::Base
  enum analysis_type: %w(gwasser gapit)
  enum status: %w(idle running success failure)

  # NOTE: there is :meta attribute stored as json

  belongs_to :owner, class_name: "User"
  has_many :data_files, class_name: "Analysis::DataFile", dependent: :destroy

  validates :owner, :name, presence: true
  validates :name, length: { maximum: 250 }
  validates :associated_pid, numericality: { only_integer: true, allow_nil: true }

  scope :recent_first, -> { order(updated_at: :desc) }
  scope :finished, -> { where(status: statuses.values_at(:success, :failure)) }

  def std_out
    data_files.std_out.first
  end

  def std_err
    data_files.std_err.first
  end

  def finished?
    success? || failure?
  end

  def plant_trial_based?
    meta["plant_trial_id"].present?
  end
end
