module AnalysesHelper
  def new_analysis_button
    link_to "Perform data analysis", new_analysis_path, class: 'btn btn-primary'
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
end
