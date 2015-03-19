require 'rails_helper'

RSpec.describe PlantLine do
  it 'dropped genus species subtaxa columns' do
    pl = create(:plant_line)
    expect{ pl.genus }.to raise_error NoMethodError
    expect{ pl.species }.to raise_error NoMethodError
    expect{ pl.subtaxa }.to raise_error NoMethodError
  end

  describe '#grid_data' do
    it 'returns empty result when no plant lines found' do
      expect(PlantLine.grid_data(plant_line_names: [1])).to be_empty
    end

    it 'orders populations by common name' do
      plids = create_list(:plant_line, 3).map(&:plant_line_name)
      gd = PlantLine.grid_data(query: { plant_line_name: plids })
      expect(gd.map(&:first)).to eq plids.sort
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

      gd = PlantLine.grid_data(
        query: { plant_line_name: [pl.plant_line_name] }
      )
      expect(gd.count).to eq 1
      expect(gd[0][1..-1]).to eq %w(tt cn pln) + [de] + %w(dob o)
    end

    it 'will not get all when no param permitted' do
      # NOTE: means - strong params should prevent passing {} to where
      create(:plant_line)
      expect(PlantLine.grid_data(query: { common_name: 'cn' })).to be_empty
      expect(PlantLine.grid_data(query: {})).to be_empty
    end

    it 'will only query by permitted params' do
      create(:plant_line, common_name: 'cn', plant_line_name: 'pln')
      create(:plant_line, common_name: 'cn', plant_line_name: 'nlp')
      create(:plant_line, common_name: 'nc', plant_line_name: 'pln')
      gd = PlantLine.grid_data(
        query: { common_name: 'cn', plant_line_name: ['pln'] }
      )
      expect(gd.count).to eq 2
      expect(gd.map(&:first)).to match_array ['pln', 'pln']
    end

    context 'when associated with plant population' do
      before(:each) do
        @pls = create_list(:plant_line, 3)
        @pp = create(:plant_population)
        create(:plant_population_list, plant_population: @pp, plant_line: @pls[0])
        create(:plant_population_list, plant_population: @pp, plant_line: @pls[1])
      end

      it 'supports querying by associated objects' do
        gd = PlantLine.grid_data(
          query: {
            'plant_populations.plant_population_id' => @pp.plant_population_id
          }
        )
        expect(gd.count).to eq 2
        expect(gd.map(&:first)).
          to match_array [@pls[0].plant_line_name, @pls[1].plant_line_name]
      end

      it 'supports multi-criteria queries' do
        gd = PlantLine.grid_data(
          query: {
            'plant_populations.plant_population_id' => @pp.plant_population_id,
            plant_line_name: [@pls[1].plant_line_name]
          }
        )
        expect(gd.count).to eq 1
        expect(gd[0][0]).to eq @pls[1].plant_line_name
      end
    end
  end
end
