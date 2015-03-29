module DataTablesHelper
  def datatables_source
    url_for(controller: controller_name, action: action_name, query: params[:query])
  end

  def datatable_tag
    content_tag(
      :table,
      class: 'table table-condensed data-table',
      id: controller_name.dasherize,
      data: { ajax: datatables_source }
    ) do
      content_tag(:thead) do
        content_tag(:tr) do
          yield
        end
      end
    end
  end
end
