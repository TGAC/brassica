require 'rails_helper'

RSpec.describe Api::AssociationFinder do
  describe '#has_many_associations' do
    it "returns association data" do
      pv_assocs = described_class.new(PlantVariety).has_many_associations
      pp_assocs = described_class.new(PlantPopulation).has_many_associations

      expect(pv_assocs.map(&:name)).to match_array %w(plant_lines)
      expect(pv_assocs.first.to_h).to include(
        name: 'plant_lines',
        primary_key: 'id',
        param: 'plant_line_ids',
        klass: PlantLine
      )

      # FIXME add plant_lines when HMT associations are handled too
      expect(pp_assocs.map(&:name)).to match_array %w(linkage_maps population_loci
        plant_trials plant_population_lists)
    end
  end

  describe '#has_and_belongs_to_many_associations' do
    it "returns association data" do
      pv_assocs = described_class.new(PlantVariety).has_and_belongs_to_many_associations
      pp_assocs = described_class.new(PlantPopulation).has_and_belongs_to_many_associations

      expect(pv_assocs.map(&:name)).to match_array %w(countries_registered
        countries_of_origin)

      expect(pp_assocs).to be_empty
    end
  end
end
