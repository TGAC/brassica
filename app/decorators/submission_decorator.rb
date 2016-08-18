class SubmissionDecorator < Draper::Decorator
  delegate_all

  def self.decorate!(submission)
    return submission if submission.is_a?(SubmissionDecorator)

    case submission.submission_type
    when "population"
      PlantPopulationSubmissionDecorator.decorate(submission)
    when "trial"
      PlantTrialSubmissionDecorator.decorate(submission)
    else
      raise NotImplementedError
    end
  end

  def submission_type_tag
    h.content_tag(
      :span,
      I18n.t("submission.submission_type.#{object.submission_type}") + ':',
      class: 'text'
    )
  end

  def further_details
    raise NotImplementedError, "Must be implemented by subclasses"
  end

  def details_path
    if object.submitted_object
      h.data_tables_path(self_url_params)
    else
      '#'
    end
  end

  def details_url
    if object.submitted_object
      h.data_tables_url(self_url_params)
    end
  end

  def doi
    object.doi ? h.link_to(object.doi, "http://dx.doi.org/#{object.doi}") : ''
  end

  def label
    raise NotImplementedError, "Must be implemented by subclasses"
  end

  private

  def self_url_params
    return unless object.submitted_object
    {
      model: object.associated_model.table_name,
      query: {
        id: object.submitted_object.id
      }
    }
  end
end
