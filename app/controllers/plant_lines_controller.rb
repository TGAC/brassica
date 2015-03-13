class PlantLinesController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json do
        plant_lines = PlantLine.grid_data(grid_data_params)
        grid_data = ApplicationDecorator.decorate(plant_lines)
        render json: grid_data.as_grid_data
      end
    end
  end

  private

  def grid_data_params
    params.permit(:search,
                  query: [
                    'plant_populations.plant_population_id',
                    plant_line_name: []
                  ])
  end
end
