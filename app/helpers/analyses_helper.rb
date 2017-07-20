module AnalysesHelper
  def new_analysis_button
    link_to "Perform new analysis", new_analysis_path, class: 'btn btn-primary'
  end

  def delete_analysis_data_file_button(data_file, options = {})
    if data_file
      url = analyses_data_file_path(data_file.id)
    else
      url = ''
    end

    options = options.merge(remote: true, method: :delete)

    link_to "Delete", url, options
  end

  def analysis_status_label(analysis)
    text = t(analysis.status, scope: %i(analysis status))
    content_tag(:span, text, class: "analysis-status analysis-status-#{analysis.status}")
  end

  def analysis_data_file_template_link(data_type)
    link_to "downloadable template", new_analyses_data_file_path(data_type: data_type),
      id: "analysis_#{data_type}_template_download"
  end
end
