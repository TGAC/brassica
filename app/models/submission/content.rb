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
      merge(step => current_step_content.merge(step_content.stringify_keys))
  end

  def append(step, step_content)
    raise Submission::InvalidStep, "No step #{step}" unless submission.steps.include?(step.to_s)
    step_content = sanitize(step_content.to_h)
    current_step_content = submission.read_attribute(:content)[step.to_s] || {}

    step_content.stringify_keys.each do |attr, val|
      current_val = current_step_content[attr] || val.class.new

      if val.is_a?(Hash) && current_val.is_a?(Hash)
        step_content[attr] = current_val.merge(val)
      elsif val.is_a?(Array) && current_val.is_a?(Array)
        step_content[attr] = current_val | val
      else
        raise "Cannot append content for '#{attr}'"
      end
    end

    submission.content = submission.read_attribute(:content).merge(step => step_content)
  end

  def clear(step)
    raise Submission::InvalidStep, "No step #{step}" unless submission.steps.include?(step.to_s)
    submission.content = submission.
      read_attribute(:content).
      merge(step => {})
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
