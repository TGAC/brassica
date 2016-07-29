class SubmissionDecorator < Draper::Decorator
  delegate_all

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
      Rails.application.routes.url_helpers.data_tables_path(
        model: object.associated_model.table_name,
        query: {
          id: object.submitted_object.id
        }
      )
    else
      '#'
    end
  end

  def doi
    object.doi ? h.link_to(object.doi, "http://dx.doi.org/#{object.doi}") : ''
  end

  def label
    raise NotImplementedError, "Must be implemented by subclasses"
  end
end
