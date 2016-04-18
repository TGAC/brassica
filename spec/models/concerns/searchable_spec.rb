require 'rails_helper'

RSpec.describe Searchable do
  describe '.indexed_json_structure' do
    it 'returns proper json structure' do
      # Chosen three examples
      proper = {
        only: [
          :map_position
        ],
        include: {
          marker_assay: { only: [:marker_assay_name] },
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
          :sequence_identifier,
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

  describe "callbacks", :elasticsearch do
    let(:es) { PlantLine.__elasticsearch__.client }
    let(:index) { PlantLine.index_name }

    context "after create" do
      it "indexes record on creation if published" do
        plant_line = create(:plant_line, published: true)

        expect(es.exists(id: plant_line.id, index: index)).to be_truthy
      end

      it "does not index record on creation if not published" do
        plant_line = create(:plant_line, published: false)

        expect(es.exists(id: plant_line.id, index: index)).to be_falsey
      end
    end

    context "after update" do
      let!(:published_plant_line) { create(:plant_line, published: true) }
      let!(:unpublished_plant_line) { create(:plant_line, published: false) }

      it "indexes record" do
        unpublished_plant_line.update_attribute(:published, true)

        expect(es.exists(id: published_plant_line.id, index: index)).to be_truthy
      end

      it "removes record from index" do
        published_plant_line.update_attribute(:published, false)

        expect(es.exists(id: published_plant_line.id, index: index)).to be_falsey
      end
    end

    context "after destroy" do
      let!(:published_plant_line) { create(:plant_line, published: true) }
      let!(:unpublished_plant_line) { create(:plant_line, published: false) }

      it "removes record from index" do
        published_plant_line.destroy
        unpublished_plant_line.destroy

        expect(es.exists(id: published_plant_line.id, index: index)).to be_falsey
        expect(es.exists(id: unpublished_plant_line.id, index: index)).to be_falsey
      end
    end
  end
end
