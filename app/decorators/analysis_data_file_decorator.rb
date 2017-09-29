class AnalysisDataFileDecorator < Draper::Decorator
  delegate_all

  def as_json(*)
    if new_record?
      super.merge(
        errors: formatted_errors
      )
    else
      super.merge(
        errors: formatted_errors,
        delete_url: delete_url
      )
    end
  end

  def delete_url
    Rails.application.routes.url_helpers.analyses_data_file_path(object)
  end

  def formatted_errors
    errors = object.errors.dup
    # Remove duplicated paperclip validation messages
    errors[:file].reject! { |msg| errors[:file_file_name].include?(msg) }
    errors.full_messages
  end
end
