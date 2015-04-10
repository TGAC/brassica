require 'rails_helper'

RSpec.describe PlantPopulation do
  describe '#filter' do
    before(:each) do
      @pp = create(:plant_population, canonical_population_name: 'cpn')
    end

    it 'will not allow search at all' do
      search = PlantPopulation.filter(search: { canonical_population_name: 'n' })
      expect(search.count).to eq 0
    end

    it 'will only query by permitted params' do
      search = PlantPopulation.filter(
        query: { canonical_population_name: 'cpn' }
      )
      expect(search.count).to eq 0
      search = PlantPopulation.filter(
        query: { id: @pp.id }
      )
      expect(search.count).to eq 1
      expect(search[0].id).to eq @pp.id
    end
  end

  describe '#table_data' do
    it 'returns empty result when no plant population is present' do
      expect(PlantPopulation.table_data).to be_empty
    end

    it 'properly calculates associated plant lines number' do
      pls = create_list(:plant_line, 3)
      pps = create_list(:plant_population, 3)
      create(:plant_population_list, plant_population: pps[0], plant_line: pls[0])
      create(:plant_population_list, plant_population: pps[0], plant_line: pls[1])
      create(:plant_population_list, plant_population: pps[1], plant_line: pls[2])
      create(:plant_population_list, plant_population: pps[1], plant_line: pls[1])
      gd = PlantPopulation.table_data
      expect(gd).not_to be_empty
      expect(gd.size).to eq 3
      expect(gd.map{ |pp| pp[-4] }).to contain_exactly 2, 2, 0
    end

    it 'orders populations by population name' do
      ppids = create_list(:plant_population, 3).map(&:name)
      expect(PlantPopulation.table_data.map(&:first)).to eq ppids.sort
    end

    it 'gets proper columns' do
      fpl = create(:plant_line)
      mpl = create(:plant_line)
      pp = create(:plant_population,
                  female_parent_line: fpl,
                  male_parent_line: mpl)

      gd = PlantPopulation.table_data
      expect(gd.count).to eq 1
      data = [
        pp.name,
        pp.taxonomy_term.name,
        pp.canonical_population_name,
        fpl.plant_line_name,
        mpl.plant_line_name,
        pp.population_type.population_type,
        0
      ]
      expect(gd[0][0..-4]).to eq data
    end
  end
end
