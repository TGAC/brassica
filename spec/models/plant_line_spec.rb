require 'rails_helper'

RSpec.describe PlantLine do
  it 'dropped genus species subtaxa columns' do
    pl = create(:plant_line)
    expect{ pl.genus }.to raise_error NoMethodError
    expect{ pl.species }.to raise_error NoMethodError
    expect{ pl.subtaxa }.to raise_error NoMethodError
  end

  it 'does not need owner for updates' do
    pl = create(:plant_line)
    pl.update_attribute(:user_id, nil)
    pl.plant_line_name = 'pln'
    pl.save
    expect(pl.valid?).to be_truthy
    expect(pl.plant_line_name).to eq 'pln'
  end

  it 'requires owner for new lines' do
    expect{ create(:plant_line, user: nil) }.
        to raise_error ActiveRecord::RecordInvalid
  end

  describe '#filter' do
    before(:each) do
      create(:plant_line, common_name: 'cn', plant_line_name: 'pln')
    end

    it 'searches plant_line_name' do
      create(:plant_line, plant_line_name: 'pln pln')
      search = PlantLine.filter(search: { plant_line_name: 'n pl' })
      expect(search.count).to eq 1
      expect(search.first.plant_line_name).to eq 'pln pln'
    end

    it 'will only search by permitted params' do
      search = PlantLine.filter(search: { common_name: 'n' })
      expect(search.count).to eq 0
    end

    it 'will not get all when no param permitted' do
      # NOTE: means - strong params should prevent passing {} to where
      expect(PlantLine.filter(query: { common_name: 'cn' })).to be_empty
      expect(PlantLine.filter(query: {})).to be_empty
    end

    it 'will only query by permitted params' do
      plname = ('a'..'z').to_a.shuffle[0,8].join
      pl = create(:plant_line, common_name: 'nc', plant_line_name: plname)
      search = PlantLine.filter(
        query: { common_name: 'cn', id: pl.id }
      )
      expect(search.count).to eq 1
      expect(search.first.plant_line_name).to eq plname
    end

    context 'when associated with plant population' do
      before(:each) do
        @pls = create_list(:plant_line, 3)
        @pp = create(:plant_population)
        create(:plant_population_list, plant_population: @pp, plant_line: @pls[0])
        create(:plant_population_list, plant_population: @pp, plant_line: @pls[1])
      end

      it 'supports querying by associated objects' do
        search = PlantLine.filter(
          query: {
            'plant_populations.id' => @pp.id
          }
        )
        expect(search.count).to eq 2
        expect(search.map(&:plant_line_name)).
          to match_array [@pls[0].plant_line_name, @pls[1].plant_line_name]
      end

      it 'supports multi-criteria queries' do
        search = PlantLine.filter(
          query: {
            'plant_populations.id' => @pp.id,
            id: @pls[1].id
          }
        )
        expect(search.count).to eq 1
        expect(search[0].plant_line_name).to eq @pls[1].plant_line_name
      end

      it 'supports both search and query criteria combined' do
        search = PlantLine.filter(
          query: {
            'plant_populations.id' => @pp.id
          },
          search: { 'plant_lines.plant_line_name' => @pls[1].plant_line_name[1..-2] }
        )
        expect(search.count).to eq 1
        expect(search[0].plant_line_name).to eq @pls[1].plant_line_name
      end
    end
  end

  describe '#pluck_columns' do
    it 'gets proper data table columns' do
      pl = create(:plant_line, plant_variety: create(:plant_variety))

      plucked = PlantLine.pluck_columns
      expect(plucked.count).to eq 1
      expect(plucked[0]).to eq [
        pl.taxonomy_term.name,
        pl.plant_line_name,
        pl.common_name,
        pl.plant_variety.plant_variety_name,
        pl.previous_line_name,
        pl.genetic_status,
        pl.data_owned_by,
        pl.organisation,
        pl.plant_variety.id,
        pl.id
      ]
    end
  end

  describe '#table_data' do
    it 'returns empty result when no plant lines found' do
      expect(PlantLine.table_data({})).to be_empty
    end

    it 'orders plant lines by plant line name' do
      pp = create(:plant_population)
      pls = create_list(:plant_line, 3, plant_populations: [pp])
      td = PlantLine.table_data(query: { 'plant_populations.id': pp.id })
      expect(td.map(&:second)).to eq pls.map(&:plant_line_name).sort
    end
  end
end
