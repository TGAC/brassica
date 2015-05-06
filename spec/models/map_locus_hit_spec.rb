require 'rails_helper'

RSpec.describe MapLocusHit do
  describe '#filter' do
    it 'will query by permitted params' do
      pending 'MLH model specs waiting for #233 fix'
      fail

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
        mlh.map_position,
        mlh.population_locus.mapping_locus,
        mlh.linkage_map.linkage_map_label,
        mlh.linkage_group.linkage_group_label,
        mlh.associated_sequence_id,
        mlh.sequence_source_acronym,
        mlh.atg_hit_seq_id,
        mlh.atg_hit_seq_source,
        mlh.bac_hit_seq_id,
        mlh.bac_hit_seq_source,
        mlh.bac_hit_name,
        mlh.linkage_map.id,
        mlh.linkage_group.id,
        mlh.population_locus.id
      ]
    end
  end
end
