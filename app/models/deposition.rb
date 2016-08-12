class Deposition
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  define_model_callbacks :initialize, only: :after
  def initialize(attributes = {})
    run_callbacks :initialize do
      super(attributes)
    end
  end

  attr_accessor :submission, :user, :title, :description, :creators, :contributors, :related_identifiers
  attr_writer :title, :description, :creators, :contributors, :related_identifiers

  # NOTE: Depositions will work in two modes
  #  - with associated submissions (depositing submitted data to an external service)
  #  - with table data filtered by user (depositing that data to an external service)
  # Hence either submission or user should be present.
  # TODO TEMP: currently only the submission-based mode is implemented and supported.

  validates :title, :creators, :description, presence: true
  validates :submission, presence: true, unless: :user
  validates :user, presence: true, unless: :submission

  after_initialize :set_default_metadata

  def documents_to_deposit
    submission ? document_exporter.documents : {}
  end

  private

  def set_default_metadata
    if submission
      decorated = SubmissionDecorator.decorate!(submission)

      self.title = "#{I18n.t("submission.submission_type.#{decorated.submission_type}")}: #{decorated.name}" unless self.title
      self.description = decorated.description unless self.description
      self.contributors = submission.user.full_name unless self.contributors
      self.creators = [
        { name: submission.user.full_name, affiliation: decorated.affiliation }
      ]
      if decorated.bip_link
        self.related_identifiers = [
          {
            relation: 'isSupplementedBy',
            identifier: decorated.bip_link
          }
        ]
      end
    elsif user
      self.creators = [{ name: user.full_name }]
    end
  end

  def document_exporter
    raise ArgumentError, 'No submission to deposit.' unless submission
    if submission.population?
      Submission::PlantPopulationExporter.new(submission)
    elsif submission.trial?
      Submission::PlantTrialExporter.new(submission)
    else
      raise NotImplementedError,
            "Unable to deposit #{submission.submission_type} submission."
    end
  end
end
