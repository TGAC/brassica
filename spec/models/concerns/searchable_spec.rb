require 'rails_helper'

RSpec.describe Searchable do
  describe '#indexed_json_structure' do
    it 'returns proper json structure' do
      # Chosen three examples
      proper = {
        only: [
          :marker_assay_name,
          :map_position
        ],
        include: {
          population_locus: { only: [:mapping_locus] },
          linkage_group: { only: [:linkage_group_label] }
        }
      }
      expect(MapPosition.indexed_json_structure).to eq proper

      proper = {
        only: [
          :consensus_group_assignment,
          :canonical_marker_name,
          :associated_sequence_id,
          :sequence_source_acronym,
          :atg_hit_seq_id,
          :atg_hit_seq_source,
          :bac_hit_seq_id,
          :bac_hit_seq_source,
          :bac_hit_name
        ],
        include: {
          linkage_map: { only: [:linkage_map_label] },
          linkage_group: { only: [:linkage_group_label] },
          population_locus: { only: [:mapping_locus] },
          map_position: { only: [:map_position] }
        }
      }
      expect(MapLocusHit.indexed_json_structure).to eq proper

      proper = {
        only: [
          :plant_line_name,
          :common_name,
          :previous_line_name,
          :genetic_status,
          :data_owned_by,
          :organisation
        ],
        include: {
          taxonomy_term: { only: [:name] },
          plant_variety: { only: [:plant_variety_name] }
        }
      }
      expect(PlantLine.indexed_json_structure).to eq proper
    end
  end
end
