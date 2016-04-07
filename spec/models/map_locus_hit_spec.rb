require 'rails_helper'

RSpec.describe MapLocusHit do
  describe '#filter' do
    it 'will query by permitted params' do
      mlhs = create_list(:map_locus_hit, 2)
      filtered = MapLocusHit.filter(
        query: { 'population_loci.id' => mlhs[0].population_locus.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mlhs[0]
      filtered = MapLocusHit.filter(
        query: { 'linkage_maps.id' => mlhs[0].linkage_map.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mlhs[0]
      filtered = MapLocusHit.filter(
        query: { 'linkage_groups.id' => mlhs[0].linkage_group.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mlhs[0]
      filtered = MapLocusHit.filter(
        query: { 'map_positions.id' => mlhs[0].map_position.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mlhs[0]
    end
  end

  describe '#table_data' do
    it 'gets proper data table columns' do
      mlh = create(:map_locus_hit)

      table_data = MapLocusHit.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        mlh.consensus_group_assignment,
        mlh.canonical_marker_name,
        mlh.map_position.map_position,
        mlh.associated_sequence_id,
        mlh.sequence_source_acronym,
        mlh.atg_hit_seq_id,
        mlh.atg_hit_seq_source,
        mlh.bac_hit_seq_id,
        mlh.bac_hit_seq_source,
        mlh.bac_hit_name,
        mlh.map_position.id,
        mlh.linkage_map.id,
        mlh.linkage_group.id,
        mlh.population_locus.id
      ]
    end

    it 'retrieves published data only' do
      u = create(:user)
      mlh1 = create(:map_locus_hit, user: u, published: true)
      mlh2 = create(:map_locus_hit, user: u, published: false)

      mlhd = MapLocusHit.table_data
      expect(mlhd.count).to eq 1

      mlhd = MapLocusHit.table_data(nil, u.id)
      expect(mlhd.count).to eq 2
    end
  end
end
