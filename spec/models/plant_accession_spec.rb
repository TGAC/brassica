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
      plucked = PlantAccession.pluck_columns
      expect(plucked.count).to eq 1
      expect(plucked[0]).to eq [
        pa.plant_accession,
        pa.plant_line.plant_line_name,
        pa.plant_accession_derivation,
        pa.accession_originator,
        pa.originating_organisation,
        pa.year_produced,
        pa.date_harvested,
        pa.plant_scoring_units.count,
        pa.plant_line.id,
        pa.id
      ]
    end

    it 'retrieves published data only' do
      u = create(:user)
      pa1 = create(:plant_accession, user: u, published: true)
      pa2 = create(:plant_accession, user: u, published: false)

      pad = PlantAccession.table_data
      expect(pad.count).to eq 1

      User.current_user_id = u.id

      pad = PlantAccession.table_data
      expect(pad.count).to eq 2
    end
  end
end
