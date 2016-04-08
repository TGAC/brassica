class Deposition
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  define_model_callbacks :initialize, only: :after
  def initialize(attributes = {})
    run_callbacks :initialize do
      super(attributes)
    end
  end

  attr_accessor :submission, :user, :title, :description, :creators
  attr_writer :title, :description, :creators

  # NOTE: Depositions will work in two modes
  #  - with associated submissions (depositing submitted data to an external service)
  #  - with table data filtered by user (depositing that data to an external service)
  # Hence either submission or user should be present

  validates :title, :creators, :description, presence: true
  validates :submission, presence: true, unless: :user
  validates :user, presence: true, unless: :submission

  after_initialize :set_default_metadata

  private

  def set_default_metadata
    if submission
      self.title = "#{I18n.t("submission.submission_type.#{submission.submission_type}")}: #{submission.object_name}" unless self.title
      self.description = submission.object_description unless self.description
      self.creators = [{ name: submission.user.full_name }]
    elsif user
      self.creators = [{ name: user.full_name }]
    end
  end
end
