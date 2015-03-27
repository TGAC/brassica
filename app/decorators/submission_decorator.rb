class SubmissionDecorator < Draper::Decorator
  delegate_all

  def submission_type
    h.content_tag(
      :span,
      I18n.t("submission.submission_type.#{object.submission_type}") + ':',
      class: 'text'
    )
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
