class PlantPopulationsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        render json: data_grid
      end
    end
  end


  private

  def data_grid
    plant_populations = PlantPopulation.grid_data
    data = plant_populations.map do |pp,c|
      pp[2] = '' if meaningless?(pp[2])
      pp[3] = '' if meaningless?(pp[3])
      pp + [c]
    end

    {
        draw: 1,
        recordsTotal: plant_populations.size,
        recordsFiltered: plant_populations.size,
        data: data
    }
  end

  def meaningless?(value)
    ['unspecified', 'not applicable', 'none'].include? value
  end
end
