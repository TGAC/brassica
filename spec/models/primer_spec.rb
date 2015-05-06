require 'rails_helper'

RSpec.describe Primer do
  describe '#filter' do
    it 'will query by permitted params' do
      ps = create_list(:primer, 2)
      filtered = Primer.filter(
        query: { 'id' => ps[0].id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq ps[0]
    end
  end

  describe '#table_data' do
    it 'gets proper data table columns' do
      p = create(:primer)

      table_data = Primer.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        p.primer,
        p.sequence,
        p.sequence_id,
        p.sequence_source_acronym,
        p.description,
        p.marker_assays_a_count,
        p.marker_assays_b_count,
        p.id
      ]
    end
  end
end
