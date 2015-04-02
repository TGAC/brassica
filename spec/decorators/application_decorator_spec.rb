require 'rails_helper'

RSpec.describe ApplicationDecorator do
  describe '#as_grid_data' do
    it 'returns proper datatables hash' do
      pps = create_list(:plant_population, 4)
      gd = ApplicationDecorator.decorate(PlantPopulation.table_data)
      expect(gd.as_grid_data[:recordsTotal]).to eq 4
      expect(gd.as_grid_data[:data].size).to eq 4
      expect(gd.as_grid_data[:data].map{ |pp| pp[-3] }).to match_array pps.map(&:id)
    end
  end
end
