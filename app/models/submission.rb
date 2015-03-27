class Submission < ActiveRecord::Base

  STEPS = %w(step01 step02 step03 step04)

  enum submission_type: %i(population traits qtl linkage_map)

  belongs_to :user

  validates :user, presence: true
  validates :submission_type, presence: true
  validates :step, inclusion: { in: STEPS }

  before_validation :set_defaults, on: :create

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

  def finalize
    raise CantFinalize unless last_step?
    transaction do
      PlantPopulationFinalizer.new(self).call
      self.finalized = true
      save!
    end
  end

  def steps
    STEPS
  end

  def name
    [I18n.l(created_at, format: :short), content.step01.try(:name)].compact.join(' ')
  end

  private

  def set_defaults
    self.step = STEPS.first
    self.content = Hash[STEPS.zip(STEPS.count.times.map {})]
  end

  CantStepForward = Class.new(RuntimeError)
  CantStepBack = Class.new(RuntimeError)
  CantFinalize = Class.new(RuntimeError)
  InvalidStep = Class.new(ArgumentError)

end
