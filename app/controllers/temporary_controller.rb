class TemporaryController < ApplicationController
  def data
    fields = %w(plant_variety_name
                genus
                species
                subtaxa
                entered_by_whom
                date_entered
                data_provenance
                data_status).join(',')
    data = PlantVariety.connection.
                        execute("SELECT #{fields} FROM plant_varieties").
                        values

    response = {
      draw: 1,
      recordsTotal: PlantVariety.count,
      recordsFiltered: PlantVariety.count,
      data: data
    }

    render json: response, layout: false
  end
end
