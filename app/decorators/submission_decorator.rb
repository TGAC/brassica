class SubmissionDecorator < Draper::Decorator
  delegate_all

  def submission_type
    I18n.t("submission.submission_type.#{object.submission_type}") + ':'
  end

  def further_details
    raise Exception.new('Should be extended by subclasses')
  end

  def details_path
    raise Exception.new('Should be extended by subclasses')
  end

  def label
    raise Exception.new('Should be extended by subclasses')
  end
end
