class Submission::Content < OpenStruct
  def initialize(submission)
    self.submission = submission

    pairs = submission.read_attribute(:content).map { |step, step_content| [step, OpenStruct.new(step_content)] }
    pairs = Hash[pairs]
    submission.steps.each { |step| pairs[step] = {} unless pairs.key?(step) }
    super(pairs)
  end

  def update(step, step_content)
    submission.content = submission.read_attribute(:content).merge(step => step_content.to_h)
  end

  private
  attr_accessor :submission
end
