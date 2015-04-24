class Submission::Content < OpenStruct
  def initialize(submission)
    self.submission = submission

    pairs = submission.read_attribute(:content).map { |step, step_content| [step, OpenStruct.new(step_content)] }
    pairs = Hash[pairs]
    submission.steps.each { |step| pairs[step] = OpenStruct.new unless pairs.key?(step) }
    super(pairs)
  end

  def update(step, step_content)
    raise Submission::InvalidStep, "No step #{step}" unless submission.steps.include?(step.to_s)
    submission.content = submission.read_attribute(:content).merge(step => step_content.to_h)
  end

  private
  attr_accessor :submission
end
