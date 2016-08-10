require 'rails_helper'

RSpec.describe PlantAccession do
  describe '#filter' do
    it 'will query by permitted params' do
      pas = create_list(:plant_accession, 2)
      filtered = PlantAccession.filter(
        query: { 'id' => pas[0].id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq pas[0]
    end
  end

  describe '#pluck_columns' do
    it 'gets proper data table columns' do
      pa = create(:plant_accession)

      create_list(:plant_scoring_unit, 3, plant_accession: pa)
      plucked = PlantAccession.table_data
      expect(plucked.count).to eq 1
      expect(plucked[0]).to eq [
        pa.plant_accession,
        pa.plant_line.plant_line_name,
        nil,
        pa.plant_accession_derivation,
        pa.originating_organisation,
        pa.year_produced,
        pa.date_harvested,
        pa.plant_scoring_units.count,
        pa.plant_line.id,
        nil,
        pa.id
      ]
    end

    it 'gets plant variety name through related plant line' do
      pl = create(:plant_line, plant_variety: create(:plant_variety))
      pa = create(:plant_accession, plant_line: pl)

      plucked = PlantAccession.table_data
      expect(plucked.count).to eq 1
      expect(plucked[0][1]).to eq pa.plant_line.plant_line_name
      expect(plucked[0][2]).to eq pa.plant_line.plant_variety.plant_variety_name
      expect(plucked[0][-2]).to eq pa.plant_line.plant_variety.id
    end

    it 'retrieves published data only' do
      u = create(:user)
      create(:plant_accession, user: u, published: true)
      create(:plant_accession, user: u, published: false)

      pad = PlantAccession.table_data
      expect(pad.count).to eq 1

      pad = PlantAccession.table_data(nil, u.id)
      expect(pad.count).to eq 2
    end
  end

  context 'linking to pl and pv' do
    let!(:pl) { create(:plant_line) }
    let!(:pv) { create(:plant_variety) }

    it 'does not permit simultaneous linking to PL and PV' do
      pa = build(:plant_accession, plant_line: pl, plant_variety: pv)
      expect(pa).to_not be_valid
      expect(pa.errors[:plant_line_id]).to include 'A plant accession may not be simultaneously linked to a plant line and a plant variety.'
      expect(pa.errors[:plant_variety_id]).to include 'A plant accession may not be simultaneously linked to a plant line and a plant variety.'
    end

    it 'does not permit PL and PV to both be blank' do
      pa = build(:plant_accession, plant_line: nil, plant_variety: nil)
      expect(pa).to_not be_valid
      expect(pa.errors[:plant_line_id]).to include 'A plant accession must be linked to either a plant line or a plant variety.'
      expect(pa.errors[:plant_variety_id]).to include 'A plant accession must be linked to either a plant line or a plant variety.'
    end

    it 'permits linking to either PL or PV' do
      pa1 = build(:plant_accession, plant_line: pl, plant_variety: nil)
      pa2 = build(:plant_accession, plant_variety: pv, plant_line: nil)
      expect(pa1).to be_valid
      expect(pa2).to be_valid
    end

    it 'properly serializes pv.name' do
      pv = create(:plant_variety)
      pl = create(:plant_line, plant_variety: pv)
      pa1 = create(:plant_accession, plant_line: pl, plant_variety: nil)
      pa2 = create(:plant_accession, plant_line: nil, plant_variety: pv)

      td = PlantAccession.table_data
      td.each do |item|
        expect(item[2]).to eq pv.plant_variety_name
      end
    end
  end
end
