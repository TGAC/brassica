module DataTablesHelper
  def datatables_source
    data_tables_path(
      query: params[:query],
      model: model_param
    )
  end

  def datatable_tag
    content_tag(
      :table,
      class: 'table table-condensed data-table',
      id: model_param.dasherize,
      data: { ajax: datatables_source }
    ) do
      content_tag(:thead) do
        content_tag(:tr) do
          yield
        end
      end
    end
  end

  def active_tab_label
    case model_param
      when 'plant_populations', 'plant_lines', 'plant_varieties'
        :plant_populations
      when 'plant_trials', 'trait_descriptors'
        :trait_descriptors
      else
        :plant_populations
    end
  end

  def tab_link(label, path)
    active = active_tab_label == label
    html_class = active ? 'active' : ''
    content_tag :li, role: 'presentation', class: html_class do
      link_to t("browse_tabs.#{label}"), active ? '#' : path
    end
  end

  def browse_tabs
    {
      plant_populations: data_tables_path(model: :plant_populations),
      trait_descriptors: data_tables_path(model: :trait_descriptors)
    }
  end

  def back_button
    unless browse_tabs.keys.include? model_param.to_sym
      link_to 'TEMP LINK BACK', browse_tabs[active_tab_label]
    end
  end

  def model_param
    if params[:model].present?
      params[:model]
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
end
