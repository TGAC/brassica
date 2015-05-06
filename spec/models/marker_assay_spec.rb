require 'rails_helper'

RSpec.describe MarkerAssay do
  describe '#filter' do
    it 'will query by permitted params' do
      mas = create_list(:marker_assay, 2)
      filtered = MarkerAssay.filter(
        query: { 'probes.id' => mas[0].probe.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mas[0]
      filtered = MarkerAssay.filter(
        query: { 'primer_a_id' => mas[0].primer_a.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mas[0]
      filtered = MarkerAssay.filter(
        query: { 'primer_b_id' => mas[0].primer_b.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mas[0]
    end
  end

  describe '#table_data' do
    it 'gets proper data table columns' do
      ma = create(:marker_assay)
      create_list(:population_locus, 2, marker_assay: ma)

      table_data = MarkerAssay.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        ma.marker_assay_name,
        ma.canonical_marker_name,
        ma.marker_type,
        ma.primer_a.primer,
        ma.primer_b.primer,
        ma.separation_system,
        ma.probe.probe_name,
        ma.population_loci.count,
        ma.primer_a.id,
        ma.primer_b.id,
        ma.probe.id,
        ma.id
      ]
    end
  end
end
