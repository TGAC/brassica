class Submission < ActiveRecord::Base

  STEPS = %w(step01 step02 step03 step04)

  belongs_to :user

  validates :user, presence: true
  validates :step, inclusion: { in: STEPS }

  before_validation :set_defaults, on: :create

  def content
    pairs = read_attribute(:content).map { |step, step_content| [step, OpenStruct.new(step_content)] }
    pairs = Hash[pairs]
    STEPS.each { |step| pairs[step] = {} unless pairs.key?(step) }
    OpenStruct.new(pairs)
  end

  def step_forward
    return if last_step? # TODO maybe raise?
    idx = STEPS.index(step)
    self.step = STEPS[idx + 1]
    save!
  end

  def step_back
    return if first_step? # TODO maybe raise?
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
    self.finalized = true
    save!
  end

  private

  def set_defaults
    self.step = STEPS.first
    self.content = Hash[STEPS.zip(STEPS.count.times.map {})]
  end
end
