require 'rails_helper'

RSpec.describe Probe do
  describe '#filter' do
    it 'will query by permitted params' do
      ps = create_list(:probe, 2)
      filtered = Probe.filter(
        query: { 'id' => ps[0].id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq ps[0]
    end
  end

  describe '#table_data' do
    it 'gets proper data table columns' do
      p = create(:probe)

      table_data = Probe.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        p.taxonomy_term.name,
        p.probe_name,
        p.clone_name,
        p.date_described,
        p.sequence_id,
        p.sequence_source_acronym,
        p.marker_assays_count,
        p.id
      ]
    end

    it 'retrieves published data only' do
      u = create(:user)
      pr1 = create(:probe, user: u, published: true)
      pr2 = create(:probe, user: u, published: false)

      prd = Probe.table_data
      expect(prd.count).to eq 1

      prd = Probe.table_data(nil, u.id)
      expect(prd.count).to eq 2
    end
  end
end
