class PlantPopulationsDecorator < ApplicationDecorator
  delegate_all

  def as_grid_data
    data = object.map do |pp,c|
      pp[2] = '' if meaningless?(pp[2])
      pp[3] = '' if meaningless?(pp[3])
      pp + [c]
    end
    datatables_input(data)
  end
end
