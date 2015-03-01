require 'rails_helper'

RSpec.describe PlantLine, type: :model do
  describe '#grid_data' do
    it 'returns empty result when no plant lines found' do
      expect(PlantLine.grid_data([1])).to be_empty
    end

    it 'orders populations by common name' do
      pl1 = create(:plant_line)
      pl2 = create(:plant_line)
      pl3 = create(:plant_line)
      ids = [pl2, pl1, pl3].map(&:plant_line_name)
      expect(PlantLine.grid_data(ids).map(&:first)).to eq ids.sort
    end
  end
end
