require 'rails_helper'

RSpec.describe PlantPopulation do
  describe '#drop_dummies' do
    it 'returns empty result when no plant population is present' do
      expect(PlantPopulation.drop_dummies).to eq []
    end

    it 'removes empty canonical name records' do
      pp1 = create(:plant_population)
      pp2 = create(:plant_population)
      create(:plant_population, canonical_population_name: '')

      expect(PlantPopulation.drop_dummies).to contain_exactly pp1, pp2
    end
  end

  describe '#grid_data' do
    it 'returns empty result when no plant population is present' do
      expect(PlantPopulation.grid_data).to be_empty
    end

    it 'properly calculates associated plant lines number' do
      pls = create_list(:plant_line, 3)
      pps = create_list(:plant_population, 3)
      create(:plant_population_list, plant_population: pps[0], plant_line: pls[0])
      create(:plant_population_list, plant_population: pps[0], plant_line: pls[1])
      create(:plant_population_list, plant_population: pps[1], plant_line: pls[2])
      create(:plant_population_list, plant_population: pps[1], plant_line: pls[1])
      gd = PlantPopulation.grid_data
      expect(gd).not_to be_empty
      expect(gd.size).to eq 3
      expect(gd.map(&:last)).to contain_exactly 2, 2, 0
    end

    it 'filters out dummy populations' do
      create(:plant_population)
      create(:plant_population, canonical_population_name: '')
      expect(PlantPopulation.grid_data.size).to eq 1
      expect(PlantPopulation.grid_data.values).to contain_exactly 1
    end

    it 'orders populations by population name' do
      ppids = create_list(:plant_population, 3).map(&:plant_population_id)
      expect(PlantPopulation.grid_data.map(&:first)).to eq ppids.sort
    end

    it 'gets proper columns' do
      fpl = create(:plant_line)
      mpl = create(:plant_line)
      create(:plant_population,
             species: 'ssp',
             canonical_population_name: 'cpn',
             female_parent_line: fpl,
             male_parent_line: mpl,
             population_type: 'pp_type')

      gd = PlantPopulation.grid_data
      expect(gd.count).to eq 1
      data = ['ssp', 'cpn', fpl.plant_line_name, mpl.plant_line_name, 'pp_type', 0]
      expect(gd[0][1..-1]).to eq data
    end
  end
end
