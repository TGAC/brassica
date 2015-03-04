require 'rails_helper'

RSpec.describe PlantPopulationsDecorator do
  describe '#as_grid_data' do
    it 'returns proper datatables hash' do
      create_list(:plant_population, 4)
      gd = PlantPopulationsDecorator.decorate(PlantPopulation.grid_data)
      expect(gd.as_grid_data[:recordsTotal]).to eq 4
      expect(gd.as_grid_data[:data].size).to eq 4
      expect(gd.as_grid_data[:data][1].size).to eq 6
    end
  end
end
