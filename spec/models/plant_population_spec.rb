require 'rails_helper'

RSpec.describe PlantPopulation, type: :model do
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

    it 'groups populations by multiple columns' do
      create(:plant_population, species: 's', canonical_population_name: 'cpn')
      create(:plant_population, species: 's', canonical_population_name: 'cpn')
      create(:plant_population, species: 's', canonical_population_name: 'CPN')

      gd = PlantPopulation.grid_data
      expect(gd).not_to be_empty
      expect(gd.size).to eq 2
      expect(gd.keys).to contain_exactly(
        %w(s cpn unspecified unspecified unspecified),
        %w(s CPN unspecified unspecified unspecified)
      )
      expect(gd.values).to contain_exactly 2, 1
    end

    it 'filters out dummy populations' do
      create(:plant_population)
      create(:plant_population, canonical_population_name: '')
      expect(PlantPopulation.grid_data.size).to eq 1
      expect(PlantPopulation.grid_data.values).to contain_exactly 1
    end

    it 'orders populations by canonical name' do
      create(:plant_population, species: 's', canonical_population_name: 'A')
      create(:plant_population, species: 's', canonical_population_name: 'X')
      create(:plant_population, species: 's', canonical_population_name: 'B')

      expect(PlantPopulation.grid_data.keys.map(&:second)).to eq %w(A B X)
    end
  end
end
