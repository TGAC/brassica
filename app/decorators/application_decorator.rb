class ApplicationDecorator < Draper::Decorator
  delegate_all

  def as_grid_data
    datatables_input(object)
  end


  protected

  def datatables_input(data)
    {
      draw: 1,
      recordsTotal: data.size,
      recordsFiltered: data.size,
      data: data
    }
  end

  def meaningless?(value)
    ['unspecified', 'not applicable', 'none'].include? value
  end
end
