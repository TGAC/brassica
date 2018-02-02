class Submission::Content < OpenStruct
  def initialize(submission)
    self.submission = submission

    super(read_content)
  end

  def update(step, new_content)
    raise Submission::InvalidStep, "No step #{step}" unless submission.steps.include?(step.to_s)

    new_content = sanitize(new_content.to_h)
    current_content = read_content
    current_content["last_step"] = step if update_step?(step)

    submission.content = current_content.merge(new_content.stringify_keys)
  end

  def append(step, new_content)
    raise Submission::InvalidStep, "No step #{step}" unless submission.steps.include?(step.to_s)

    new_content = sanitize(new_content.to_h)
    current_content = read_content
    current_content["last_step"] = step if update_step?(step)

    new_content.stringify_keys.each do |attr, val|
      current_val = current_content[attr]

      if val.is_a?(Hash) && current_val.is_a?(Hash)
        new_content[attr] = current_val.merge(val)
      elsif val.is_a?(Array) && current_val.is_a?(Array)
        new_content[attr] = current_val | val
      elsif current_val
        raise "Cannot append content for '#{attr}'"
      end
    end

    submission.content = current_content.merge(new_content.stringify_keys)
  end

  def clear(attr)
    current_content = read_content
    current_content.delete(attr.to_s)

    submission.content = current_content
  end

  def to_h
    super.except(*restricted_attrs.map(&:to_sym))
  end

  private

  attr_accessor :submission

  def read_content
    submission.read_attribute(:content) || {}
  end

  def sanitize(content)
    content.each do |attr, val|
      fail ArgumentError, "Property '#{attr}' is restricted" if restricted_attrs.include?(attr.to_s)
      if val.is_a?(Array)
        content[attr] = val.select(&:present?)
      end
    end
  end

  def update_step?(step)
    last_step.nil? || submission.steps.index(step.to_s) > submission.steps.index(last_step)
  end

  def restricted_attrs
    %w(last_step)
  end
end
