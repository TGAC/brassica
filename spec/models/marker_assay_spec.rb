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
      pls = create_list(:population_locus, 2, marker_assay: ma)
      create_list(:map_position, 3, marker_assay: ma, population_locus: pls[0])

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
        ma.map_positions.count,
        ma.primer_a.id,
        ma.primer_b.id,
        ma.probe.id,
        ma.id
      ]
    end

    it 'retrieves published data only' do
      u1 = create(:user)
      u2 = create(:user)

      pra1 = create(:primer, user: u2, published: true)
      prb1 = create(:primer, user: u2, published: false)
      pra2 = create(:primer, user: u1, published: true)
      prb2 = create(:primer, user: u1, published: false)

      pr1 = create(:probe, user: u2, published: true)
      pr2 = create(:probe, user: u1, published: false)

      ma1 = create(:marker_assay, primer_a: pra1, primer_b: prb1, probe: pr1, user: u1, published: true)
      ma2 = create(:marker_assay, primer_a: pra2, primer_b: prb2, probe: pr2, user: u1, published: false)

      mad = MarkerAssay.table_data

      expect(mad.count).to eq 1
      expect(mad.first[3]).to eq pra1.primer
      expect(mad.first[4]).to be_nil

      User.current_user_id = u1.id

      mad = MarkerAssay.table_data

      expect(mad.count).to eq 2
      expect(([pra1.primer, pra2.primer] & [mad.first[3], mad.second[3]]).size).to eq 2
      expect(([prb1.primer, prb2.primer] & [mad.first[4], mad.second[4]]).size).to eq 1
    end
  end
end
