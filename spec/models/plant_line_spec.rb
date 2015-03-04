require 'rails_helper'

RSpec.describe PlantLine, type: :model do
  describe '#grid_data' do
    it 'returns empty result when no plant lines found' do
      expect(PlantLine.grid_data([1])).to be_empty
    end

    it 'orders populations by common name' do
      pl1,pl2,pl3 = create_list(:plant_line, 3)
      ids = [pl2, pl1, pl3].map(&:plant_line_name)
      expect(PlantLine.grid_data(ids).map(&:first)).to eq ids.sort
    end

    it 'gets proper columns' do
      tt = create(:taxonomy_term, name: 'tt')
      de = Date.today
      pl = create(:plant_line,
                   taxonomy_term: tt,
                   common_name: 'cn',
                   previous_line_name: 'pln',
                   date_entered: de,
                   data_owned_by: 'dob',
                   organisation: 'o')

      first_line = PlantLine.grid_data(pl.plant_line_name)[0]
      expect(first_line[1..-1]).to eq %w(tt cn pln) + [de] + %w(dob o)
    end
  end
end
