class Submission < ActiveRecord::Base

  STEPS = %w(step01 step02 step03 step04)

  enum submission_type: %i(population trial qtl linkage_map)

  belongs_to :user
  has_many :uploads, class_name: 'Submission::Upload'

  validates :user, presence: true
  validates :submission_type, presence: true
  validates :step, inclusion: { in: STEPS }
  validates :submitted_object_id, presence: true, if: 'finalized?'
  validates :submitted_object_id, uniqueness: { scope: :submission_type}, if: 'finalized?'
  validates :publishable, inclusion: { in: [true, false] }

  before_validation :set_defaults, on: :create
  before_save :apply_content_adjustments

  scope :publishable, -> { where(publishable: true) }
  scope :finalized, -> { where(finalized: true) }
  scope :recent_first, -> { order(updated_at: :desc) }

  def content
    Content.new(self)
  end

  def step_forward
    raise CantStepForward if last_step?
    idx = STEPS.index(step)
    self.step = STEPS[idx + 1]
    save!
  end

  def step_back
    raise CantStepBack if first_step?
    idx = STEPS.index(step)
    self.step = STEPS[idx - 1]
    save!
  end

  def first_step?
    step == STEPS.first
  end

  def last_step?
    step == STEPS.last
  end

  def reset_step(to_step = 0)
    to_step = 0 if to_step.nil? || to_step.to_i >= STEPS.length || to_step.to_i < 0
    self.step = STEPS[to_step.to_i]
    save!
  end

  def finalize
    raise CantFinalize unless last_step?
    case submission_type
    when 'population'
      PlantPopulationFinalizer.new(self).call
    when 'trial'
      PlantTrialFinalizer.new(self).call
    else
      raise CantFinalize
    end

  end

  def submitted_object
    finalized? ? associated_model.find(submitted_object_id) : nil
  end

  def revocable?
    submitted_object && submitted_object.revocable?
  end

  def revocable_until
    submitted_object.try(:revocable_until)
  end

  def published_on
    submitted_object.try(:published_on)
  end

  def steps
    STEPS
  end

  def name
    [I18n.l(created_at, format: :short), content.step01.try(:name)].compact.join(' ')
  end

  def associated_model
    case submission_type
    when 'population'
      PlantPopulation
    when 'trial'
      PlantTrial
    when 'qtl'
      Qtl
    when 'linkage_map'
      LinkageMap
    else
      nil
    end
  end

  private

  def set_defaults
    self.step = STEPS.first
    self.content = Hash[STEPS.zip(STEPS.count.times.map {})] if content.blank?
  end

  def apply_content_adjustments
    return unless trial?
    return unless content_changed?

    step02_was = content_was[:step02] || {}
    step02 = content[:step02] || {}

    old_trait_descriptor_list = (step02_was[:trait_descriptor_list] || []).map(&:to_s)
    new_trait_descriptor_list = (step02[:trait_descriptor_list] || []).map(&:to_s)

    if old_trait_descriptor_list != new_trait_descriptor_list
      content.clear(:step03)
    end
  end

  CantStepForward = Class.new(RuntimeError)
  CantStepBack = Class.new(RuntimeError)
  CantFinalize = Class.new(RuntimeError)
  InvalidStep = Class.new(ArgumentError)
end
