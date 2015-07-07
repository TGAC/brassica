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
    step_content = sanitize(step_content.to_h)
    current_step_content = submission.read_attribute(:content)[step.to_s] || {}
    submission.content = submission.
      read_attribute(:content).
      merge(step => current_step_content.merge(step_content))
  end

  private
  attr_accessor :submission

  def sanitize(step_content)
    step_content.each do |attr, val|
      if val.is_a?(Array)
        step_content[attr] = val.select(&:present?)
      end
    end
  end
end
